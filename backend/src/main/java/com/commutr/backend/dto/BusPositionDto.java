package com.commutr.backend.dto;

import com.commutr.backend.entity.BusPosition;
import java.time.Instant;

public class BusPositionDto {
    private Long busId;
    private Long routeId;
    private Double latitude;
    private Double longitude;
    private Double speedKmh;
    private Double heading;
    private Double accuracyMeters;
    private Integer crowdCount;
    private String congestionLevel;
    private Instant lastUpdatedAt;
    private Boolean isLive;

    public BusPositionDto() {}

    public BusPositionDto(Long busId, Long routeId, Double latitude, Double longitude,
                          Double speedKmh, Double heading, Double accuracyMeters,
                          Integer crowdCount, String congestionLevel, Instant lastUpdatedAt, Boolean isLive) {
        this.busId = busId;
        this.routeId = routeId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.speedKmh = speedKmh;
        this.heading = heading;
        this.accuracyMeters = accuracyMeters;
        this.crowdCount = crowdCount;
        this.congestionLevel = congestionLevel;
        this.lastUpdatedAt = lastUpdatedAt;
        this.isLive = isLive;
    }

    public static BusPositionDto fromEntity(BusPosition entity) {
        if (entity == null) return null;
        return new BusPositionDto(
                entity.getBusId(),
                entity.getRouteId(),
                entity.getLatitude(),
                entity.getLongitude(),
                entity.getSpeedKmh(),
                entity.getHeading(),
                entity.getAccuracyMeters(),
                entity.getCrowdCount(),
                entity.getCongestionLevel(),
                entity.getLastUpdatedAt(),
                entity.getIsLive()
        );
    }

    public Long getBusId() { return busId; }
    public void setBusId(Long busId) { this.busId = busId; }

    public Long getRouteId() { return routeId; }
    public void setRouteId(Long routeId) { this.routeId = routeId; }

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

    public Integer getCrowdCount() { return crowdCount; }
    public void setCrowdCount(Integer crowdCount) { this.crowdCount = crowdCount; }

    public String getCongestionLevel() { return congestionLevel; }
    public void setCongestionLevel(String congestionLevel) { this.congestionLevel = congestionLevel; }

    public Instant getLastUpdatedAt() { return lastUpdatedAt; }
    public void setLastUpdatedAt(Instant lastUpdatedAt) { this.lastUpdatedAt = lastUpdatedAt; }

    public Boolean getIsLive() { return isLive; }
    public void setIsLive(Boolean live) { isLive = live; }
}
