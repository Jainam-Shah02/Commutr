package com.commutr.backend.controller;

import com.commutr.backend.entity.Trip;
import com.commutr.backend.repository.TripRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class TripController {

    private final TripRepository tripRepository;

    public TripController(TripRepository tripRepository) {
        this.tripRepository = tripRepository;
    }

    @GetMapping("/trips")
    public ResponseEntity<List<Trip>> getAllTrips() {
        return ResponseEntity.ok(tripRepository.findAll());
    }

    @GetMapping("/routes/{routeId}/trips")
    public ResponseEntity<List<Trip>> getTripsByRoute(@PathVariable Long routeId) {
        return ResponseEntity.ok(tripRepository.findByRouteId(routeId));
    }
}
