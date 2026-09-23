package com.commutr.backend.dto;

import java.time.Instant;

public class HealthResponse {
    private String status;
    private Instant timestamp;
    private String service;
    private String database;

    public HealthResponse() {}

    public HealthResponse(String status, Instant timestamp, String service, String database) {
        this.status = status;
        this.timestamp = timestamp;
        this.service = service;
        this.database = database;
    }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }

    public String getService() { return service; }
    public void setService(String service) { this.service = service; }

    public String getDatabase() { return database; }
    public void setDatabase(String database) { this.database = database; }
}
