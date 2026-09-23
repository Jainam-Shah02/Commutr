package com.commutr.backend.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String deviceSessionId;

    @Column(nullable = false)
    private String role = "PASSENGER";

    @Column(nullable = false)
    private Instant createdAt = Instant.now();

    public User() {}

    public User(String deviceSessionId, String role) {
        this.deviceSessionId = deviceSessionId;
        this.role = role != null ? role : "PASSENGER";
        this.createdAt = Instant.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getDeviceSessionId() { return deviceSessionId; }
    public void setDeviceSessionId(String deviceSessionId) { this.deviceSessionId = deviceSessionId; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
