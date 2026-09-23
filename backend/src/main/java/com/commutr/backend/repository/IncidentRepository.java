package com.commutr.backend.repository;

import com.commutr.backend.entity.Incident;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IncidentRepository extends JpaRepository<Incident, Long> {
    List<Incident> findByRouteId(Long routeId);
    List<Incident> findByBusId(Long busId);
}
