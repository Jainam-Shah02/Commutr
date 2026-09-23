package com.commutr.backend.service;

import com.commutr.backend.dto.BusPositionDto;
import com.commutr.backend.dto.GpsObservationRequest;
import com.commutr.backend.dto.GpsObservationResponse;
import com.commutr.backend.entity.Bus;
import com.commutr.backend.entity.BusPosition;
import com.commutr.backend.repository.BusPositionRepository;
import com.commutr.backend.repository.BusRepository;
import com.commutr.backend.repository.GpsObservationRepository;
import com.commutr.backend.websocket.BusPositionWebSocketHandler;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BusPositionTrackingServiceTest {

    @Mock
    private GpsValidationService gpsValidationService;

    @Mock
    private GpsObservationRepository gpsObservationRepository;

    @Mock
    private BusPositionRepository busPositionRepository;

    @Mock
    private BusRepository busRepository;

    @Mock
    private BusPositionWebSocketHandler webSocketHandler;

    private BusPositionTrackingService trackingService;

    @BeforeEach
    void setUp() {
        trackingService = new BusPositionTrackingService(
                gpsValidationService,
                gpsObservationRepository,
                busPositionRepository,
                busRepository,
                webSocketHandler
        );
    }

    @Test
    @DisplayName("Valid GPS observation updates bus position and triggers WebSocket broadcast")
    void testProcessValidObservation() {
        Instant now = Instant.now();
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-001", 19.1932, 72.9692, 25.0, 45.0, 4.0, now
        );

        when(gpsValidationService.validate(any(), any())).thenReturn(GpsValidationService.ValidationResult.valid());
        when(busRepository.findById(1L)).thenReturn(Optional.of(new Bus("TMT-50-A", 1L, 45, "ACTIVE", "MH-04")));
        when(busPositionRepository.findByBusId(1L)).thenReturn(Optional.empty());

        BusPosition savedPos = new BusPosition(1L, 1L, 19.1932, 72.9692, 25.0, 45.0, 4.0, 1, "MODERATE", now, true);
        when(busPositionRepository.save(any(BusPosition.class))).thenReturn(savedPos);

        GpsObservationResponse response = trackingService.processObservation(request);

        assertEquals("ACCEPTED", response.getStatus());
        assertEquals(1L, response.getBusId());

        verify(gpsObservationRepository).save(any());
        verify(busPositionRepository).save(any(BusPosition.class));
        verify(webSocketHandler).broadcast(any(BusPositionDto.class));
    }

    @Test
    @DisplayName("Invalid GPS observation is rejected and does not update bus position or broadcast")
    void testProcessInvalidObservation() {
        Instant now = Instant.now();
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-001", 0.0, 0.0, 25.0, 45.0, 4.0, now
        );

        when(gpsValidationService.validate(any(), any()))
                .thenReturn(GpsValidationService.ValidationResult.invalid("Null Island coordinates"));

        GpsObservationResponse response = trackingService.processObservation(request);

        assertEquals("REJECTED", response.getStatus());
        assertTrue(response.getMessage().contains("Null Island coordinates"));

        verify(gpsObservationRepository).save(any());
        verify(busPositionRepository, never()).save(any());
        verify(webSocketHandler, never()).broadcast(any());
    }
}
