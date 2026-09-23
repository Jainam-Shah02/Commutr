package com.commutr.backend.dto;

public class RouteStopDto {
    private Long routeStopId;
    private Long stopId;
    private String stopName;
    private Double latitude;
    private Double longitude;
    private String code;
    private Integer sequence;
    private Double distanceFromStartKm;
    private Integer scheduledMinutesFromStart;

    public RouteStopDto() {}

    public RouteStopDto(Long routeStopId, Long stopId, String stopName, Double latitude, Double longitude,
                        String code, Integer sequence, Double distanceFromStartKm, Integer scheduledMinutesFromStart) {
        this.routeStopId = routeStopId;
        this.stopId = stopId;
        this.stopName = stopName;
        this.latitude = latitude;
        this.longitude = longitude;
        this.code = code;
        this.sequence = sequence;
        this.distanceFromStartKm = distanceFromStartKm;
        this.scheduledMinutesFromStart = scheduledMinutesFromStart;
    }

    public Long getRouteStopId() { return routeStopId; }
    public void setRouteStopId(Long routeStopId) { this.routeStopId = routeStopId; }

    public Long getStopId() { return stopId; }
    public void setStopId(Long stopId) { this.stopId = stopId; }

    public String getStopName() { return stopName; }
    public void setStopName(String stopName) { this.stopName = stopName; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public Integer getSequence() { return sequence; }
    public void setSequence(Integer sequence) { this.sequence = sequence; }

    public Double getDistanceFromStartKm() { return distanceFromStartKm; }
    public void setDistanceFromStartKm(Double distanceFromStartKm) { this.distanceFromStartKm = distanceFromStartKm; }

    public Integer getScheduledMinutesFromStart() { return scheduledMinutesFromStart; }
    public void setScheduledMinutesFromStart(Integer scheduledMinutesFromStart) { this.scheduledMinutesFromStart = scheduledMinutesFromStart; }
}
