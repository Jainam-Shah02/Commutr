package com.commutr.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "route_stops", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"route_id", "stop_sequence"})
})
public class RouteStop {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "route_id", nullable = false)
    private Long routeId;

    @Column(name = "stop_id", nullable = false)
    private Long stopId;

    @Column(name = "stop_sequence", nullable = false)
    private Integer stopSequence;

    private Double distanceFromStartKm;
    private Integer scheduledMinutesFromStart;

    public RouteStop() {}

    public RouteStop(Long routeId, Long stopId, Integer stopSequence, Double distanceFromStartKm, Integer scheduledMinutesFromStart) {
        this.routeId = routeId;
        this.stopId = stopId;
        this.stopSequence = stopSequence;
        this.distanceFromStartKm = distanceFromStartKm;
        this.scheduledMinutesFromStart = scheduledMinutesFromStart;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getRouteId() { return routeId; }
    public void setRouteId(Long routeId) { this.routeId = routeId; }

    public Long getStopId() { return stopId; }
    public void setStopId(Long stopId) { this.stopId = stopId; }

    public Integer getStopSequence() { return stopSequence; }
    public void setStopSequence(Integer stopSequence) { this.stopSequence = stopSequence; }

    public Double getDistanceFromStartKm() { return distanceFromStartKm; }
    public void setDistanceFromStartKm(Double distanceFromStartKm) { this.distanceFromStartKm = distanceFromStartKm; }

    public Integer getScheduledMinutesFromStart() { return scheduledMinutesFromStart; }
    public void setScheduledMinutesFromStart(Integer scheduledMinutesFromStart) { this.scheduledMinutesFromStart = scheduledMinutesFromStart; }
}
