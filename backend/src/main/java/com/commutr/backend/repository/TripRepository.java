package com.commutr.backend.repository;

import com.commutr.backend.entity.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripRepository extends JpaRepository<Trip, Long> {
    List<Trip> findByRouteId(Long routeId);
    List<Trip> findByBusId(Long busId);
    List<Trip> findByStatus(String status);
}
