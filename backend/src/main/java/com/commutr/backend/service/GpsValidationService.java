package com.commutr.backend.service;

import com.commutr.backend.dto.GpsObservationRequest;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;

@Service
public class GpsValidationService {

    public static class ValidationResult {
        private final boolean valid;
        private final String reason;

        public ValidationResult(boolean valid, String reason) {
            this.valid = valid;
            this.reason = reason;
        }

        public static ValidationResult valid() {
            return new ValidationResult(true, null);
        }

        public static ValidationResult invalid(String reason) {
            return new ValidationResult(false, reason);
        }

        public boolean isValid() { return valid; }
        public String getReason() { return reason; }
    }

    public ValidationResult validate(GpsObservationRequest request, Instant serverTime) {
        if (request == null) {
            return ValidationResult.invalid("GPS observation request cannot be null");
        }

        if (request.getBusId() == null) {
            return ValidationResult.invalid("busId is required");
        }

        if (request.getDeviceSessionId() == null || request.getDeviceSessionId().trim().isEmpty()) {
            return ValidationResult.invalid("deviceSessionId is required");
        }

        Double lat = request.getLatitude();
        Double lon = request.getLongitude();

        if (lat == null || lon == null) {
            return ValidationResult.invalid("Latitude and Longitude cannot be null");
        }

        if (lat < -90.0 || lat > 90.0) {
            return ValidationResult.invalid("Latitude must be between -90.0 and +90.0, got " + lat);
        }

        if (lon < -180.0 || lon > 180.0) {
            return ValidationResult.invalid("Longitude must be between -180.0 and +180.0, got " + lon);
        }

        // Null island rejection
        if (Math.abs(lat) < 0.0001 && Math.abs(lon) < 0.0001) {
            return ValidationResult.invalid("Latitude and Longitude (0.0, 0.0) rejected as Null Island");
        }

        // Speed rejection
        if (request.getSpeedKmh() != null) {
            if (request.getSpeedKmh() < 0.0) {
                return ValidationResult.invalid("Speed cannot be negative, got " + request.getSpeedKmh());
            }
            if (request.getSpeedKmh() > 130.0) {
                return ValidationResult.invalid("Speed exceeds maximum bus operating threshold (130 km/h), got " + request.getSpeedKmh());
            }
        }

        // Heading rejection
        if (request.getHeading() != null) {
            if (request.getHeading() < 0.0 || request.getHeading() > 360.0) {
                return ValidationResult.invalid("Heading must be between 0 and 360 degrees, got " + request.getHeading());
            }
        }

        // Accuracy rejection
        if (request.getAccuracyMeters() != null) {
            if (request.getAccuracyMeters() < 0.0) {
                return ValidationResult.invalid("Accuracy cannot be negative, got " + request.getAccuracyMeters());
            }
            if (request.getAccuracyMeters() > 100.0) {
                return ValidationResult.invalid("GPS accuracy too poor (> 100m threshold), got " + request.getAccuracyMeters());
            }
        }

        // Timestamp validation
        if (request.getClientTimestamp() != null && serverTime != null) {
            Duration skew = Duration.between(request.getClientTimestamp(), serverTime).abs();
            if (skew.toMinutes() > 10) {
                return ValidationResult.invalid("Client timestamp is skewed by more than 10 minutes: " + skew.toMinutes() + " min");
            }
        }

        return ValidationResult.valid();
    }
}
