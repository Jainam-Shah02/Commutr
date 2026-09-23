package com.commutr.backend.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "bus_positions")
public class BusPosition {
    @Id
    @Column(name = "bus_id")
    private Long busId;

    @Column(name = "route_id")
    private Long routeId;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    private Double speedKmh;
    private Double heading;
    private Double accuracyMeters;

    private Integer crowdCount = 1;
    private String congestionLevel = "MODERATE";

    @Column(nullable = false)
    private Instant lastUpdatedAt = Instant.now();

    @Column(nullable = false)
    private Boolean isLive = true;

    public BusPosition() {}

    public BusPosition(Long busId, Long routeId, Double latitude, Double longitude,
                       Double speedKmh, Double heading, Double accuracyMeters,
                       Integer crowdCount, String congestionLevel, Instant lastUpdatedAt, Boolean isLive) {
        this.busId = busId;
        this.routeId = routeId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.speedKmh = speedKmh;
        this.heading = heading;
        this.accuracyMeters = accuracyMeters;
        this.crowdCount = crowdCount != null ? crowdCount : 1;
        this.congestionLevel = congestionLevel != null ? congestionLevel : "MODERATE";
        this.lastUpdatedAt = lastUpdatedAt != null ? lastUpdatedAt : Instant.now();
        this.isLive = isLive != null ? isLive : true;
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
