package com.commutr.backend.controller;

import com.commutr.backend.dto.RouteStopDto;
import com.commutr.backend.entity.Route;
import com.commutr.backend.entity.RouteStop;
import com.commutr.backend.entity.Stop;
import com.commutr.backend.repository.RouteRepository;
import com.commutr.backend.repository.RouteStopRepository;
import com.commutr.backend.repository.StopRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1")
public class RouteController {

    private final RouteRepository routeRepository;
    private final RouteStopRepository routeStopRepository;
    private final StopRepository stopRepository;

    public RouteController(RouteRepository routeRepository,
                           RouteStopRepository routeStopRepository,
                           StopRepository stopRepository) {
        this.routeRepository = routeRepository;
        this.routeStopRepository = routeStopRepository;
        this.stopRepository = stopRepository;
    }

    @GetMapping("/routes")
    public ResponseEntity<List<Route>> getAllRoutes() {
        return ResponseEntity.ok(routeRepository.findAll());
    }

    @GetMapping("/routes/{routeId}")
    public ResponseEntity<Route> getRouteById(@PathVariable Long routeId) {
        return routeRepository.findById(routeId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/routes/{routeId}/stops")
    public ResponseEntity<List<RouteStopDto>> getRouteStops(@PathVariable Long routeId) {
        List<RouteStop> routeStops = routeStopRepository.findByRouteIdOrderByStopSequenceAsc(routeId);
        if (routeStops.isEmpty()) {
            return ResponseEntity.ok(List.of());
        }

        List<Long> stopIds = routeStops.stream().map(RouteStop::getStopId).toList();
        Map<Long, Stop> stopMap = stopRepository.findAllById(stopIds).stream()
                .collect(Collectors.toMap(Stop::getId, Function.identity()));

        List<RouteStopDto> result = new ArrayList<>();
        for (RouteStop rs : routeStops) {
            Stop stop = stopMap.get(rs.getStopId());
            if (stop != null) {
                result.add(new RouteStopDto(
                        rs.getId(),
                        stop.getId(),
                        stop.getStopName(),
                        stop.getLatitude(),
                        stop.getLongitude(),
                        stop.getCode(),
                        rs.getStopSequence(),
                        rs.getDistanceFromStartKm(),
                        rs.getScheduledMinutesFromStart()
                ));
            }
        }

        return ResponseEntity.ok(result);
    }
}
