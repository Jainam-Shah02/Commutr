package com.commutr.backend.service;

import com.commutr.backend.dto.GpsObservationRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import static org.junit.jupiter.api.Assertions.*;

class GpsValidationServiceTest {

    private GpsValidationService validationService;

    @BeforeEach
    void setUp() {
        validationService = new GpsValidationService();
    }

    @Test
    @DisplayName("Should accept valid GPS observation")
    void testValidGpsObservation() {
        Instant now = Instant.now();
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-001", 19.1932, 72.9692, 28.5, 90.0, 5.0, now
        );

        GpsValidationService.ValidationResult result = validationService.validate(request, now);
        assertTrue(result.isValid());
        assertNull(result.getReason());
    }

    @Test
    @DisplayName("Should reject Null Island (0.0, 0.0)")
    void testRejectNullIsland() {
        Instant now = Instant.now();
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-001", 0.0, 0.0, 20.0, 0.0, 5.0, now
        );

        GpsValidationService.ValidationResult result = validationService.validate(request, now);
        assertFalse(result.isValid());
        assertTrue(result.getReason().contains("Null Island"));
    }

    @Test
    @DisplayName("Should reject excessive speed (> 130 km/h)")
    void testRejectExcessiveSpeed() {
        Instant now = Instant.now();
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-001", 19.1932, 72.9692, 145.0, 90.0, 5.0, now
        );

        GpsValidationService.ValidationResult result = validationService.validate(request, now);
        assertFalse(result.isValid());
        assertTrue(result.getReason().contains("exceeds maximum bus operating threshold"));
    }

    @Test
    @DisplayName("Should reject negative speed")
    void testRejectNegativeSpeed() {
        Instant now = Instant.now();
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-001", 19.1932, 72.9692, -5.0, 90.0, 5.0, now
        );

        GpsValidationService.ValidationResult result = validationService.validate(request, now);
        assertFalse(result.isValid());
        assertTrue(result.getReason().contains("Speed cannot be negative"));
    }

    @Test
    @DisplayName("Should reject poor GPS accuracy (> 100 meters)")
    void testRejectPoorAccuracy() {
        Instant now = Instant.now();
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-001", 19.1932, 72.9692, 20.0, 90.0, 250.0, now
        );

        GpsValidationService.ValidationResult result = validationService.validate(request, now);
        assertFalse(result.isValid());
        assertTrue(result.getReason().contains("GPS accuracy too poor"));
    }

    @Test
    @DisplayName("Should reject timestamp skewed by more than 10 minutes")
    void testRejectSkewedTimestamp() {
        Instant now = Instant.now();
        Instant pastTime = now.minus(25, ChronoUnit.MINUTES);
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-001", 19.1932, 72.9692, 20.0, 90.0, 5.0, pastTime
        );

        GpsValidationService.ValidationResult result = validationService.validate(request, now);
        assertFalse(result.isValid());
        assertTrue(result.getReason().contains("Client timestamp is skewed"));
    }

    @Test
    @DisplayName("Should reject latitude out of bounds")
    void testRejectLatitudeOutOfBounds() {
        Instant now = Instant.now();
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-001", 95.0, 72.9692, 20.0, 90.0, 5.0, now
        );

        GpsValidationService.ValidationResult result = validationService.validate(request, now);
        assertFalse(result.isValid());
        assertTrue(result.getReason().contains("Latitude must be between"));
    }
}
