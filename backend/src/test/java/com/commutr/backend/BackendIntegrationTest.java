package com.commutr.backend;

import com.commutr.backend.dto.GpsObservationRequest;
import com.commutr.backend.entity.Bus;
import com.commutr.backend.entity.Route;
import com.commutr.backend.entity.Stop;
import com.commutr.backend.repository.BusRepository;
import com.commutr.backend.repository.RouteRepository;
import com.commutr.backend.repository.StopRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class BackendIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private RouteRepository routeRepository;

    @Autowired
    private StopRepository stopRepository;

    @Autowired
    private BusRepository busRepository;

    @BeforeEach
    void initData() {
        if (routeRepository.findByRouteNumber("50").isEmpty()) {
            Route r = routeRepository.save(new Route("50", "Thane Stn to Manpada", "Thane Stn", "Manpada", "[]", 6.2, 28, "ACTIVE"));
            busRepository.save(new Bus("MH-04-GP-5001", r.getId(), 45, "ACTIVE", "MH 04 GP 5001"));
        }
        if (stopRepository.findByCode("TMT-STN-01").isEmpty()) {
            stopRepository.save(new Stop("Thane Station West", 19.1864, 72.9756, "TMT-STN-01"));
        }
    }

    @Test
    @DisplayName("GET /api/v1/health should return UP status and database info")
    void testHealthEndpoint() throws Exception {
        mockMvc.perform(get("/api/v1/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.service").value("commutr-backend"))
                .andExpect(jsonPath("$.database").value("OK"));
    }

    @Test
    @DisplayName("POST /api/v1/location with valid GPS should return 200 ACCEPTED and update position")
    void testValidGpsObservationEndpoint() throws Exception {
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-test", 19.1932, 72.9692, 22.0, 90.0, 4.5, Instant.now()
        );

        mockMvc.perform(post("/api/v1/location")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("ACCEPTED"))
                .andExpect(jsonPath("$.busId").value(1));

        // Verify GET /api/v1/buses/1/position returns the updated position
        mockMvc.perform(get("/api/v1/buses/1/position"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.busId").value(1))
                .andExpect(jsonPath("$.latitude").value(19.1932))
                .andExpect(jsonPath("$.longitude").value(72.9692))
                .andExpect(jsonPath("$.isLive").value(true));
    }

    @Test
    @DisplayName("POST /api/v1/location with invalid GPS (Null Island) should return 422 REJECTED")
    void testInvalidGpsObservationEndpoint() throws Exception {
        GpsObservationRequest request = new GpsObservationRequest(
                1L, "dev-session-test", 0.0, 0.0, 20.0, 0.0, 5.0, Instant.now()
        );

        mockMvc.perform(post("/api/v1/location")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.status").value("REJECTED"))
                .andExpect(jsonPath("$.message", containsString("Null Island")));
    }

    @Test
    @DisplayName("GET /api/v1/routes should return route list")
    void testGetRoutes() throws Exception {
        mockMvc.perform(get("/api/v1/routes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", not(empty())));
    }

    @Test
    @DisplayName("GET /api/v1/stops should return stops list")
    void testGetStops() throws Exception {
        mockMvc.perform(get("/api/v1/stops"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", not(empty())));
    }
}
