package com.commutr.backend.controller;

import com.commutr.backend.entity.Stop;
import com.commutr.backend.repository.StopRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class StopController {

    private final StopRepository stopRepository;

    public StopController(StopRepository stopRepository) {
        this.stopRepository = stopRepository;
    }

    @GetMapping("/stops")
    public ResponseEntity<List<Stop>> getAllStops() {
        return ResponseEntity.ok(stopRepository.findAll());
    }

    @GetMapping("/stops/{stopId}")
    public ResponseEntity<Stop> getStopById(@PathVariable Long stopId) {
        return stopRepository.findById(stopId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
