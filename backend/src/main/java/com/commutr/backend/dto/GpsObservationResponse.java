package com.commutr.backend.dto;

import java.time.Instant;

public class GpsObservationResponse {
    private String status; // ACCEPTED or REJECTED
    private String message;
    private Long busId;
    private Instant recordedAt;

    public GpsObservationResponse() {}

    public GpsObservationResponse(String status, String message, Long busId, Instant recordedAt) {
        this.status = status;
        this.message = message;
        this.busId = busId;
        this.recordedAt = recordedAt;
    }

    public static GpsObservationResponse accepted(Long busId) {
        return new GpsObservationResponse("ACCEPTED", "GPS observation accepted and processed", busId, Instant.now());
    }

    public static GpsObservationResponse rejected(Long busId, String reason) {
        return new GpsObservationResponse("REJECTED", reason, busId, Instant.now());
    }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Long getBusId() { return busId; }
    public void setBusId(Long busId) { this.busId = busId; }

    public Instant getRecordedAt() { return recordedAt; }
    public void setRecordedAt(Instant recordedAt) { this.recordedAt = recordedAt; }
}
