package com.commutr.backend.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "incidents")
public class Incident {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "route_id")
    private Long routeId;

    @Column(name = "bus_id")
    private Long busId;

    @Column(nullable = false)
    private String incidentType;

    private String description;

    private Double latitude;
    private Double longitude;

    @Column(nullable = false)
    private Instant reportedAt = Instant.now();

    @Column(nullable = false)
    private String severity = "MEDIUM";

    public Incident() {}

    public Incident(Long routeId, Long busId, String incidentType, String description,
                    Double latitude, Double longitude, String severity) {
        this.routeId = routeId;
        this.busId = busId;
        this.incidentType = incidentType;
        this.description = description;
        this.latitude = latitude;
        this.longitude = longitude;
        this.reportedAt = Instant.now();
        this.severity = severity != null ? severity : "MEDIUM";
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getRouteId() { return routeId; }
    public void setRouteId(Long routeId) { this.routeId = routeId; }

    public Long getBusId() { return busId; }
    public void setBusId(Long busId) { this.busId = busId; }

    public String getIncidentType() { return incidentType; }
    public void setIncidentType(String incidentType) { this.incidentType = incidentType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public Instant getReportedAt() { return reportedAt; }
    public void setReportedAt(Instant reportedAt) { this.reportedAt = reportedAt; }

    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }
}
