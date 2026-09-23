-- Commutr Initial Seed Data (Thane Municipal Transport)

-- 1. Routes
INSERT INTO routes (id, route_number, route_name, origin_name, destination_name, total_distance_km, estimated_duration_min, status)
VALUES 
  (1, '50', 'Thane Station West → Manpada', 'Thane Station West', 'Manpada', 6.2, 28, 'ACTIVE'),
  (2, '2', 'Thane Station West → Balkum', 'Thane Station West', 'Balkum', 5.1, 24, 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

-- 2. Stops
INSERT INTO stops (id, stop_name, latitude, longitude, code)
VALUES
  (1, 'Thane Station West', 19.1864, 72.9756, 'TMT-STN-01'),
  (2, 'Panchpakhadi', 19.1932, 72.9692, 'TMT-PCH-02'),
  (3, 'Nitin Company Junction', 19.1995, 72.9680, 'TMT-NIT-03'),
  (4, 'Cadbury Junction', 19.2045, 72.9710, 'TMT-CAD-04'),
  (5, 'Majiwada Junction', 19.2138, 72.9785, 'TMT-MAJ-05'),
  (6, 'Kapurbawdi', 19.2225, 72.9810, 'TMT-KPB-06'),
  (7, 'Manpada', 19.2365, 72.9765, 'TMT-MAN-07'),
  (8, 'Balkum Naka', 19.2240, 72.9920, 'TMT-BLK-08')
ON CONFLICT (id) DO NOTHING;

-- 3. Route Stops (TMT 50: Stops 1 to 7)
INSERT INTO route_stops (id, route_id, stop_id, stop_sequence, distance_from_start_km, scheduled_minutes_from_start)
VALUES
  (1, 1, 1, 1, 0.0, 0),
  (2, 1, 2, 2, 1.1, 4),
  (3, 1, 3, 3, 2.0, 8),
  (4, 1, 4, 4, 2.8, 12),
  (5, 1, 5, 5, 4.0, 18),
  (6, 1, 6, 6, 5.0, 22),
  (7, 1, 7, 7, 6.2, 28)
ON CONFLICT (id) DO NOTHING;

-- Route Stops (TMT 2: Stops 1, 2, 5, 8)
INSERT INTO route_stops (id, route_id, stop_id, stop_sequence, distance_from_start_km, scheduled_minutes_from_start)
VALUES
  (8, 2, 1, 1, 0.0, 0),
  (9, 2, 2, 2, 1.1, 4),
  (10, 2, 5, 3, 3.9, 17),
  (11, 2, 8, 4, 5.1, 24)
ON CONFLICT (id) DO NOTHING;

-- 4. Buses
INSERT INTO buses (id, bus_number, route_id, capacity, status, license_plate)
VALUES
  (1, 'MH-04-GP-5001', 1, 45, 'ACTIVE', 'MH 04 GP 5001'),
  (2, 'MH-04-GP-5002', 1, 45, 'ACTIVE', 'MH 04 GP 5002'),
  (3, 'MH-04-GP-2001', 2, 40, 'ACTIVE', 'MH 04 GP 2001')
ON CONFLICT (id) DO NOTHING;

-- 5. Initial Bus Positions (Live status for testing)
INSERT INTO bus_positions (bus_id, route_id, latitude, longitude, speed_kmh, heading, accuracy_meters, crowd_count, congestion_level, last_updated_at, is_live)
VALUES
  (1, 1, 19.1932, 72.9692, 24.5, 12.0, 4.2, 3, 'MODERATE', CURRENT_TIMESTAMP, true),
  (2, 1, 19.2138, 72.9785, 18.0, 45.0, 5.0, 1, 'MODERATE', CURRENT_TIMESTAMP, true),
  (3, 2, 19.1932, 72.9692, 30.0, 15.0, 3.5, 2, 'LOW', CURRENT_TIMESTAMP, true)
ON CONFLICT (bus_id) DO NOTHING;
