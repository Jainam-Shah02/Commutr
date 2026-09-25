-- Commutr Database Schema (PostgreSQL 16)

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    device_session_id VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL DEFAULT 'PASSENGER',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS routes (
    id BIGSERIAL PRIMARY KEY,
    route_number VARCHAR(50) NOT NULL UNIQUE,
    route_name VARCHAR(255) NOT NULL,
    origin_name VARCHAR(255),
    destination_name VARCHAR(255),
    polyline_json TEXT,
    total_distance_km DOUBLE PRECISION,
    estimated_duration_min INTEGER,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE IF NOT EXISTS stops (
    id BIGSERIAL PRIMARY KEY,
    stop_name VARCHAR(255) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    code VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS route_stops (
    id BIGSERIAL PRIMARY KEY,
    route_id BIGINT NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
    stop_id BIGINT NOT NULL REFERENCES stops(id) ON DELETE CASCADE,
    stop_sequence INTEGER NOT NULL,
    distance_from_start_km DOUBLE PRECISION,
    scheduled_minutes_from_start INTEGER,
    CONSTRAINT uq_route_stop_seq UNIQUE (route_id, stop_sequence)
);

CREATE TABLE IF NOT EXISTS buses (
    id BIGSERIAL PRIMARY KEY,
    bus_number VARCHAR(100) NOT NULL UNIQUE,
    route_id BIGINT REFERENCES routes(id) ON DELETE SET NULL,
    capacity INTEGER DEFAULT 45,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    license_plate VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS trips (
    id BIGSERIAL PRIMARY KEY,
    bus_id BIGINT NOT NULL REFERENCES buses(id) ON DELETE CASCADE,
    route_id BIGINT NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
    departure_time TIMESTAMP WITH TIME ZONE,
    arrival_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) NOT NULL DEFAULT 'SCHEDULED'
);

CREATE TABLE IF NOT EXISTS gps_observations (
    id BIGSERIAL PRIMARY KEY,
    bus_id BIGINT NOT NULL,
    device_session_id VARCHAR(255) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed_kmh DOUBLE PRECISION,
    heading DOUBLE PRECISION,
    accuracy_meters DOUBLE PRECISION,
    client_timestamp TIMESTAMP WITH TIME ZONE,
    server_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN NOT NULL DEFAULT TRUE,
    rejection_reason TEXT
);

CREATE INDEX IF NOT EXISTS idx_gps_obs_bus_time ON gps_observations(bus_id, server_timestamp);

CREATE TABLE IF NOT EXISTS bus_positions (
    bus_id BIGINT PRIMARY KEY,
    route_id BIGINT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed_kmh DOUBLE PRECISION,
    heading DOUBLE PRECISION,
    accuracy_meters DOUBLE PRECISION,
    crowd_count INTEGER DEFAULT 1,
    congestion_level VARCHAR(50) DEFAULT 'MODERATE',
    last_updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_live BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS incidents (
    id BIGSERIAL PRIMARY KEY,
    route_id BIGINT REFERENCES routes(id) ON DELETE SET NULL,
    bus_id BIGINT REFERENCES buses(id) ON DELETE SET NULL,
    incident_type VARCHAR(100) NOT NULL,
    description TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    reported_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    severity VARCHAR(50) NOT NULL DEFAULT 'MEDIUM'
);
