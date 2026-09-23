package com.commutr.backend.controller;

import com.commutr.backend.entity.Incident;
import com.commutr.backend.repository.IncidentRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class IncidentController {

    private final IncidentRepository incidentRepository;

    public IncidentController(IncidentRepository incidentRepository) {
        this.incidentRepository = incidentRepository;
    }

    @GetMapping("/incidents")
    public ResponseEntity<List<Incident>> getAllIncidents() {
        return ResponseEntity.ok(incidentRepository.findAll());
    }

    @GetMapping("/routes/{routeId}/incidents")
    public ResponseEntity<List<Incident>> getIncidentsByRoute(@PathVariable Long routeId) {
        return ResponseEntity.ok(incidentRepository.findByRouteId(routeId));
    }

    @PostMapping("/incidents")
    public ResponseEntity<Incident> reportIncident(@RequestBody Incident incident) {
        return ResponseEntity.ok(incidentRepository.save(incident));
    }
}
