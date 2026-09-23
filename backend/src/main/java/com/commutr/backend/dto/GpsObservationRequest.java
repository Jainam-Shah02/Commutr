package com.commutr.backend.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;

public class GpsObservationRequest {
    @NotNull(message = "busId is required")
    private Long busId;

    @NotBlank(message = "deviceSessionId is required")
    private String deviceSessionId;

    @NotNull(message = "latitude is required")
    @DecimalMin(value = "-90.0", message = "latitude must be >= -90")
    @DecimalMax(value = "90.0", message = "latitude must be <= 90")
    private Double latitude;

    @NotNull(message = "longitude is required")
    @DecimalMin(value = "-180.0", message = "longitude must be >= -180")
    @DecimalMax(value = "180.0", message = "longitude must be <= 180")
    private Double longitude;

    @DecimalMin(value = "0.0", message = "speed must be >= 0")
    @DecimalMax(value = "150.0", message = "speed must be <= 150")
    private Double speedKmh;

    @DecimalMin(value = "0.0", message = "heading must be >= 0")
    @DecimalMax(value = "360.0", message = "heading must be <= 360")
    private Double heading;

    @DecimalMin(value = "0.0", message = "accuracy must be >= 0")
    private Double accuracyMeters;

    private Instant clientTimestamp;

    public GpsObservationRequest() {}

    public GpsObservationRequest(Long busId, String deviceSessionId, Double latitude, Double longitude,
                                 Double speedKmh, Double heading, Double accuracyMeters, Instant clientTimestamp) {
        this.busId = busId;
        this.deviceSessionId = deviceSessionId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.speedKmh = speedKmh;
        this.heading = heading;
        this.accuracyMeters = accuracyMeters;
        this.clientTimestamp = clientTimestamp;
    }

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
}
