package com.commutr.backend.controller;

import com.commutr.backend.dto.BusPositionDto;
import com.commutr.backend.entity.Bus;
import com.commutr.backend.repository.BusRepository;
import com.commutr.backend.service.BusPositionTrackingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class BusController {

    private final BusRepository busRepository;
    private final BusPositionTrackingService busPositionTrackingService;

    public BusController(BusRepository busRepository, BusPositionTrackingService busPositionTrackingService) {
        this.busRepository = busRepository;
        this.busPositionTrackingService = busPositionTrackingService;
    }

    @GetMapping("/buses")
    public ResponseEntity<List<Bus>> getAllBuses() {
        return ResponseEntity.ok(busRepository.findAll());
    }

    @GetMapping("/buses/{busId}")
    public ResponseEntity<Bus> getBusById(@PathVariable Long busId) {
        return busRepository.findById(busId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/buses/{busId}/position")
    public ResponseEntity<BusPositionDto> getBusPosition(@PathVariable Long busId) {
        return busPositionTrackingService.getLatestBusPosition(busId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/routes/{routeId}/buses")
    public ResponseEntity<List<Bus>> getBusesByRoute(@PathVariable Long routeId) {
        return ResponseEntity.ok(busRepository.findByRouteId(routeId));
    }

    @GetMapping("/routes/{routeId}/buses/positions")
    public ResponseEntity<List<BusPositionDto>> getBusPositionsByRoute(@PathVariable Long routeId) {
        return ResponseEntity.ok(busPositionTrackingService.getBusPositionsByRoute(routeId));
    }
}
