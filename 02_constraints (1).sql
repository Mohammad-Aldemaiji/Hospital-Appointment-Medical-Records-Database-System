-- 02_constraints.sql
-- Domain + basic integrity constraints (PostgreSQL-friendly).

-- =========================
-- Appointment constraints
-- =========================
ALTER TABLE appointment
  ADD CONSTRAINT chk_appointment_status
  CHECK (status IN ('Scheduled','Completed','Canceled','NoShow'));

ALTER TABLE appointment
  ADD CONSTRAINT chk_appointment_time_order
  CHECK (end_time IS NULL OR start_time < end_time);

-- =========================
-- Lab order status constraints
-- =========================
ALTER TABLE lab_order
  ADD CONSTRAINT chk_lab_order_status
  CHECK (status IN ('Ordered','InProgress','Completed','Canceled'));

-- =========================
-- Weak-entity partial keys should be positive integers
-- =========================
ALTER TABLE visit
  ADD CONSTRAINT chk_visit_no_positive
  CHECK (visit_no > 0);

ALTER TABLE diagnosis
  ADD CONSTRAINT chk_diagnosis_no_positive
  CHECK (diagnosis_no > 0);

ALTER TABLE lab_order
  ADD CONSTRAINT chk_lab_order_no_positive
  CHECK (lab_order_no > 0);

ALTER TABLE prescription
  ADD CONSTRAINT chk_rx_no_positive
  CHECK (rx_no > 0);

-- =========================
-- Analytics-friendly constraints (optional but safe)
-- =========================
ALTER TABLE prescription_item
  ADD CONSTRAINT chk_duration_days_nonnegative
  CHECK (duration_days IS NULL OR duration_days >= 0);

-- =========================
-- Recommended (optional) uniqueness rules
-- =========================
-- Prevent duplicate medication names if you want a stricter catalog:
-- ALTER TABLE medication ADD CONSTRAINT uq_medication_name UNIQUE (name, strength, form);
