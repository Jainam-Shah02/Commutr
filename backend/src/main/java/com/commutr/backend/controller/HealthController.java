package com.commutr.backend.controller;

import com.commutr.backend.dto.HealthResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.Instant;

@RestController
@RequestMapping("/api/v1")
public class HealthController {

    private final DataSource dataSource;

    public HealthController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @GetMapping("/health")
    public ResponseEntity<HealthResponse> health() {
        String dbStatus = "OK";
        try (Connection conn = dataSource.getConnection()) {
            if (!conn.isValid(1)) {
                dbStatus = "DEGRADED";
            }
        } catch (Exception e) {
            dbStatus = "DOWN: " + e.getMessage();
        }

        HealthResponse response = new HealthResponse("UP", Instant.now(), "commutr-backend", dbStatus);
        return ResponseEntity.ok(response);
    }
}
