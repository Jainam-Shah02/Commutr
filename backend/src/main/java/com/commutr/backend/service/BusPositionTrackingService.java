package com.commutr.backend.service;

import com.commutr.backend.dto.BusPositionDto;
import com.commutr.backend.dto.GpsObservationRequest;
import com.commutr.backend.dto.GpsObservationResponse;
import com.commutr.backend.entity.Bus;
import com.commutr.backend.entity.BusPosition;
import com.commutr.backend.entity.GpsObservation;
import com.commutr.backend.repository.BusPositionRepository;
import com.commutr.backend.repository.BusRepository;
import com.commutr.backend.repository.GpsObservationRepository;
import com.commutr.backend.websocket.BusPositionWebSocketHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

@Service
public class BusPositionTrackingService {

    private static final Logger log = LoggerFactory.getLogger(BusPositionTrackingService.class);

    private final GpsValidationService gpsValidationService;
    private final GpsObservationRepository gpsObservationRepository;
    private final BusPositionRepository busPositionRepository;
    private final BusRepository busRepository;
    private final BusPositionWebSocketHandler webSocketHandler;

    public BusPositionTrackingService(
            GpsValidationService gpsValidationService,
            GpsObservationRepository gpsObservationRepository,
            BusPositionRepository busPositionRepository,
            BusRepository busRepository,
            BusPositionWebSocketHandler webSocketHandler) {
        this.gpsValidationService = gpsValidationService;
        this.gpsObservationRepository = gpsObservationRepository;
        this.busPositionRepository = busPositionRepository;
        this.busRepository = busRepository;
        this.webSocketHandler = webSocketHandler;
    }

    @Transactional
    public GpsObservationResponse processObservation(GpsObservationRequest request) {
        Instant serverTime = Instant.now();

        // 1. Validate observation
        GpsValidationService.ValidationResult validation = gpsValidationService.validate(request, serverTime);

        // 2. Build GpsObservation entity
        GpsObservation observation = new GpsObservation(
                request.getBusId(),
                request.getDeviceSessionId(),
                request.getLatitude(),
                request.getLongitude(),
                request.getSpeedKmh(),
                request.getHeading(),
                request.getAccuracyMeters(),
                request.getClientTimestamp()
        );
        observation.setServerTimestamp(serverTime);
        observation.setIsValid(validation.isValid());
        observation.setRejectionReason(validation.getReason());

        gpsObservationRepository.save(observation);

        if (!validation.isValid()) {
            log.warn("Rejected GPS observation for busId={}: {}", request.getBusId(), validation.getReason());
            return GpsObservationResponse.rejected(request.getBusId(), validation.getReason());
        }

        // 3. Find routeId from Bus if present
        Long routeId = null;
        Optional<Bus> busOpt = busRepository.findById(request.getBusId());
        if (busOpt.isPresent()) {
            routeId = busOpt.get().getRouteId();
        }

        // 4. Update or create BusPosition
        BusPosition busPosition = busPositionRepository.findByBusId(request.getBusId())
                .orElseGet(() -> {
                    BusPosition pos = new BusPosition();
                    pos.setBusId(request.getBusId());
                    return pos;
                });

        if (routeId != null) {
            busPosition.setRouteId(routeId);
        }
        busPosition.setLatitude(request.getLatitude());
        busPosition.setLongitude(request.getLongitude());
        busPosition.setSpeedKmh(request.getSpeedKmh());
        busPosition.setHeading(request.getHeading());
        busPosition.setAccuracyMeters(request.getAccuracyMeters());
        busPosition.setLastUpdatedAt(serverTime);
        busPosition.setIsLive(true);

        // 5. Calculate crowd estimation (recent contributing devices in past 60s)
        Instant windowStart = serverTime.minus(60, ChronoUnit.SECONDS);
        List<GpsObservation> recentObs = gpsObservationRepository.findByBusIdAndServerTimestampAfter(request.getBusId(), windowStart);
        long distinctDevices = recentObs.stream()
                .filter(GpsObservation::getIsValid)
                .map(GpsObservation::getDeviceSessionId)
                .distinct()
                .count();

        int crowdCount = Math.max(1, (int) distinctDevices);
        busPosition.setCrowdCount(crowdCount);

        // Compute congestion based on speed
        double speed = request.getSpeedKmh() != null ? request.getSpeedKmh() : 20.0;
        if (speed < 10.0) {
            busPosition.setCongestionLevel("HEAVY");
        } else if (speed < 25.0) {
            busPosition.setCongestionLevel("MODERATE");
        } else {
            busPosition.setCongestionLevel("LOW");
        }

        BusPosition saved = busPositionRepository.save(busPosition);

        // 6. Broadcast via WebSocket
        BusPositionDto dto = BusPositionDto.fromEntity(saved);
        webSocketHandler.broadcast(dto);

        log.debug("Processed and broadcast GPS observation for busId={}", request.getBusId());
        return GpsObservationResponse.accepted(request.getBusId());
    }

    public Optional<BusPositionDto> getLatestBusPosition(Long busId) {
        return busPositionRepository.findByBusId(busId).map(BusPositionDto::fromEntity);
    }

    public List<BusPositionDto> getBusPositionsByRoute(Long routeId) {
        return busPositionRepository.findByRouteId(routeId).stream()
                .map(BusPositionDto::fromEntity)
                .toList();
    }
}
