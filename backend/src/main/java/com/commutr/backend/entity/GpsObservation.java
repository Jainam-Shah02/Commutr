package com.commutr.backend.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "gps_observations")
public class GpsObservation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "bus_id", nullable = false)
    private Long busId;

    @Column(name = "device_session_id", nullable = false)
    private String deviceSessionId;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    private Double speedKmh;
    private Double heading;
    private Double accuracyMeters;

    private Instant clientTimestamp;

    @Column(nullable = false)
    private Instant serverTimestamp = Instant.now();

    @Column(nullable = false)
    private Boolean isValid = true;

    private String rejectionReason;

    public GpsObservation() {}

    public GpsObservation(Long busId, String deviceSessionId, Double latitude, Double longitude,
                          Double speedKmh, Double heading, Double accuracyMeters, Instant clientTimestamp) {
        this.busId = busId;
        this.deviceSessionId = deviceSessionId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.speedKmh = speedKmh;
        this.heading = heading;
        this.accuracyMeters = accuracyMeters;
        this.clientTimestamp = clientTimestamp;
        this.serverTimestamp = Instant.now();
        this.isValid = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getBusId() { return busId; }
    public void setBusId(Long busId) { this.busId = busId; }

    public String getDeviceSessionId() { return deviceSessionId; }
    public void setDeviceSessionId(String deviceSessionId) { this.deviceSessionId = deviceSessionId; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public Double getSpeedKmh() { return speedKmh; }
    public void setSpeedKmh(Double speedKmh) { this.speedKmh = speedKmh; }

    public Double getHeading() { return heading; }
    public void setHeading(Double heading) { this.heading = heading; }

    public Double getAccuracyMeters() { return accuracyMeters; }
    public void setAccuracyMeters(Double accuracyMeters) { this.accuracyMeters = accuracyMeters; }

    public Instant getClientTimestamp() { return clientTimestamp; }
    public void setClientTimestamp(Instant clientTimestamp) { this.clientTimestamp = clientTimestamp; }

    public Instant getServerTimestamp() { return serverTimestamp; }
    public void setServerTimestamp(Instant serverTimestamp) { this.serverTimestamp = serverTimestamp; }

    public Boolean getIsValid() { return isValid; }
    public void setIsValid(Boolean valid) { isValid = valid; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }
}
