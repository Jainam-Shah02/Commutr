package com.commutr.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "buses")
public class Bus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String busNumber;

    @Column(name = "route_id")
    private Long routeId;

    private Integer capacity = 45;

    @Column(nullable = false)
    private String status = "ACTIVE";

    private String licensePlate;

    public Bus() {}

    public Bus(String busNumber, Long routeId, Integer capacity, String status, String licensePlate) {
        this.busNumber = busNumber;
        this.routeId = routeId;
        this.capacity = capacity;
        this.status = status != null ? status : "ACTIVE";
        this.licensePlate = licensePlate;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getBusNumber() { return busNumber; }
    public void setBusNumber(String busNumber) { this.busNumber = busNumber; }

    public Long getRouteId() { return routeId; }
    public void setRouteId(Long routeId) { this.routeId = routeId; }

    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getLicensePlate() { return licensePlate; }
    public void setLicensePlate(String licensePlate) { this.licensePlate = licensePlate; }
}
