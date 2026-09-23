package com.commutr.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "routes")
public class Route {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String routeNumber;

    @Column(nullable = false)
    private String routeName;

    private String originName;
    private String destinationName;

    @Column(columnDefinition = "TEXT")
    private String polylineJson;

    private Double totalDistanceKm;
    private Integer estimatedDurationMin;

    @Column(nullable = false)
    private String status = "ACTIVE";

    public Route() {}

    public Route(String routeNumber, String routeName, String originName, String destinationName,
                 String polylineJson, Double totalDistanceKm, Integer estimatedDurationMin, String status) {
        this.routeNumber = routeNumber;
        this.routeName = routeName;
        this.originName = originName;
        this.destinationName = destinationName;
        this.polylineJson = polylineJson;
        this.totalDistanceKm = totalDistanceKm;
        this.estimatedDurationMin = estimatedDurationMin;
        this.status = status != null ? status : "ACTIVE";
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getRouteNumber() { return routeNumber; }
    public void setRouteNumber(String routeNumber) { this.routeNumber = routeNumber; }

    public String getRouteName() { return routeName; }
    public void setRouteName(String routeName) { this.routeName = routeName; }

    public String getOriginName() { return originName; }
    public void setOriginName(String originName) { this.originName = originName; }

    public String getDestinationName() { return destinationName; }
    public void setDestinationName(String destinationName) { this.destinationName = destinationName; }

    public String getPolylineJson() { return polylineJson; }
    public void setPolylineJson(String polylineJson) { this.polylineJson = polylineJson; }

    public Double getTotalDistanceKm() { return totalDistanceKm; }
    public void setTotalDistanceKm(Double totalDistanceKm) { this.totalDistanceKm = totalDistanceKm; }

    public Integer getEstimatedDurationMin() { return estimatedDurationMin; }
    public void setEstimatedDurationMin(Integer estimatedDurationMin) { this.estimatedDurationMin = estimatedDurationMin; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
