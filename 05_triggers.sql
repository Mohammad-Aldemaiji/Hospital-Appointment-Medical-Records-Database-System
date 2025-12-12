CREATE OR REPLACE FUNCTION fn_default_appointment_end_time()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.end_time IS NULL AND NEW.start_time IS NOT NULL THEN
    NEW.end_time := NEW.start_time + INTERVAL '30 minutes';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_validate_appointment_rules()
RETURNS TRIGGER AS $$
DECLARE
  new_end TIMESTAMP;
BEGIN
  new_end := COALESCE(NEW.end_time, NEW.start_time + INTERVAL '30 minutes');

  IF NEW.check_in_time IS NOT NULL AND NEW.start_time IS NOT NULL AND NEW.check_in_time > NEW.start_time THEN
    RAISE EXCEPTION 'check_in_time cannot be after start_time';
  END IF;

  IF TG_OP = 'UPDATE' AND NEW.status IS DISTINCT FROM OLD.status THEN
    IF OLD.status IN ('Completed','Canceled','NoShow') AND NEW.status <> OLD.status THEN
      RAISE EXCEPTION 'status transition not allowed: % -> %', OLD.status, NEW.status;
    END IF;
  END IF;

  IF NEW.start_time IS NOT NULL THEN
    IF EXISTS (
      SELECT 1
      FROM appointment a
      WHERE a.doctor_id = NEW.doctor_id
        AND a.appointment_id <> COALESCE(NEW.appointment_id, -1)
        AND a.status <> 'Canceled'
        AND NEW.start_time < COALESCE(a.end_time, a.start_time + INTERVAL '30 minutes')
        AND new_end > a.start_time
    ) THEN
      RAISE EXCEPTION 'overlapping appointment for doctor_id=%', NEW.doctor_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_create_visit_on_completed_appointment()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'Completed' AND (OLD.status IS DISTINCT FROM 'Completed') THEN
    IF NOT EXISTS (SELECT 1 FROM visit v WHERE v.appointment_id = NEW.appointment_id) THEN
      INSERT INTO visit (appointment_id, visit_no, created_at, started_at, ended_at, notes, diagnosis_summary)
      VALUES (
        NEW.appointment_id,
        1,
        COALESCE(NEW.start_time, CURRENT_TIMESTAMP),
        NEW.start_time,
        NEW.end_time,
        'Auto-created visit from completed appointment.',
        NULL
      );
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_appointment_default_end_time ON appointment;
CREATE TRIGGER trg_appointment_default_end_time
BEFORE INSERT OR UPDATE OF start_time, end_time
ON appointment
FOR EACH ROW
EXECUTE FUNCTION fn_default_appointment_end_time();

DROP TRIGGER IF EXISTS trg_appointment_validate_rules ON appointment;
CREATE TRIGGER trg_appointment_validate_rules
BEFORE INSERT OR UPDATE OF doctor_id, start_time, end_time, status, check_in_time
ON appointment
FOR EACH ROW
EXECUTE FUNCTION fn_validate_appointment_rules();

DROP TRIGGER IF EXISTS trg_appointment_create_visit ON appointment;
CREATE TRIGGER trg_appointment_create_visit
AFTER UPDATE OF status
ON appointment
FOR EACH ROW
EXECUTE FUNCTION fn_create_visit_on_completed_appointment();

CREATE OR REPLACE FUNCTION fn_visit_autonumber()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.visit_no IS NULL THEN
    SELECT COALESCE(MAX(v.visit_no), 0) + 1 INTO NEW.visit_no
    FROM visit v
    WHERE v.appointment_id = NEW.appointment_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_visit_autonumber ON visit;
CREATE TRIGGER trg_visit_autonumber
BEFORE INSERT
ON visit
FOR EACH ROW
EXECUTE FUNCTION fn_visit_autonumber();

CREATE OR REPLACE FUNCTION fn_diagnosis_autonumber()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.diagnosis_no IS NULL THEN
    SELECT COALESCE(MAX(d.diagnosis_no), 0) + 1 INTO NEW.diagnosis_no
    FROM diagnosis d
    WHERE d.appointment_id = NEW.appointment_id
      AND d.visit_no = NEW.visit_no;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_diagnosis_autonumber ON diagnosis;
CREATE TRIGGER trg_diagnosis_autonumber
BEFORE INSERT
ON diagnosis
FOR EACH ROW
EXECUTE FUNCTION fn_diagnosis_autonumber();

CREATE OR REPLACE FUNCTION fn_prescription_autonumber()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.rx_no IS NULL THEN
    SELECT COALESCE(MAX(p.rx_no), 0) + 1 INTO NEW.rx_no
    FROM prescription p
    WHERE p.appointment_id = NEW.appointment_id
      AND p.visit_no = NEW.visit_no;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prescription_autonumber ON prescription;
CREATE TRIGGER trg_prescription_autonumber
BEFORE INSERT
ON prescription
FOR EACH ROW
EXECUTE FUNCTION fn_prescription_autonumber();

CREATE OR REPLACE FUNCTION fn_lab_order_autonumber()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.lab_order_no IS NULL THEN
    SELECT COALESCE(MAX(lo.lab_order_no), 0) + 1 INTO NEW.lab_order_no
    FROM lab_order lo
    WHERE lo.appointment_id = NEW.appointment_id
      AND lo.visit_no = NEW.visit_no;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_lab_order_autonumber ON lab_order;
CREATE TRIGGER trg_lab_order_autonumber
BEFORE INSERT
ON lab_order
FOR EACH ROW
EXECUTE FUNCTION fn_lab_order_autonumber();
