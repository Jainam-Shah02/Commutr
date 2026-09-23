package com.commutr.backend.controller;

import com.commutr.backend.dto.GpsObservationRequest;
import com.commutr.backend.dto.GpsObservationResponse;
import com.commutr.backend.service.BusPositionTrackingService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class LocationController {

    private final BusPositionTrackingService busPositionTrackingService;

    public LocationController(BusPositionTrackingService busPositionTrackingService) {
        this.busPositionTrackingService = busPositionTrackingService;
    }

    @PostMapping("/location")
    public ResponseEntity<GpsObservationResponse> recordLocation(@Valid @RequestBody GpsObservationRequest request) {
        GpsObservationResponse response = busPositionTrackingService.processObservation(request);
        if ("ACCEPTED".equals(response.getStatus())) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(response);
        }
    }
}
