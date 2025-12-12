CREATE OR REPLACE FUNCTION sp_book_appointment(
  p_patient_id BIGINT,
  p_doctor_id BIGINT,
  p_start_time TIMESTAMP,
  p_end_time TIMESTAMP DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
  new_id BIGINT;
BEGIN
  INSERT INTO appointment (patient_id, doctor_id, start_time, end_time, status)
  VALUES (p_patient_id, p_doctor_id, p_start_time, p_end_time, 'Scheduled')
  RETURNING appointment_id INTO new_id;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_reschedule_appointment(
  p_appointment_id BIGINT,
  p_new_start_time TIMESTAMP,
  p_new_end_time TIMESTAMP DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE appointment
  SET start_time = p_new_start_time,
      end_time = p_new_end_time
  WHERE appointment_id = p_appointment_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cancel_appointment(
  p_appointment_id BIGINT
)
RETURNS VOID AS $$
BEGIN
  UPDATE appointment
  SET status = 'Canceled'
  WHERE appointment_id = p_appointment_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_mark_no_show(
  p_appointment_id BIGINT
)
RETURNS VOID AS $$
BEGIN
  UPDATE appointment
  SET status = 'NoShow'
  WHERE appointment_id = p_appointment_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_check_in(
  p_appointment_id BIGINT,
  p_check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
RETURNS VOID AS $$
BEGIN
  UPDATE appointment
  SET check_in_time = p_check_in_time
  WHERE appointment_id = p_appointment_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_complete_appointment(
  p_appointment_id BIGINT
)
RETURNS VOID AS $$
BEGIN
  UPDATE appointment
  SET status = 'Completed'
  WHERE appointment_id = p_appointment_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_visit_note(
  p_appointment_id BIGINT,
  p_visit_no INT,
  p_notes TEXT,
  p_diagnosis_summary TEXT DEFAULT NULL,
  p_started_at TIMESTAMP DEFAULT NULL,
  p_ended_at TIMESTAMP DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE visit
  SET notes = p_notes,
      diagnosis_summary = COALESCE(p_diagnosis_summary, diagnosis_summary),
      started_at = COALESCE(p_started_at, started_at),
      ended_at = COALESCE(p_ended_at, ended_at)
  WHERE appointment_id = p_appointment_id
    AND visit_no = p_visit_no;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_diagnosis(
  p_appointment_id BIGINT,
  p_visit_no INT,
  p_icd_code VARCHAR DEFAULT NULL,
  p_description TEXT,
  p_diagnosed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
RETURNS INT AS $$
DECLARE
  new_no INT;
BEGIN
  INSERT INTO diagnosis (appointment_id, visit_no, diagnosis_no, icd_code, description, diagnosed_at)
  VALUES (p_appointment_id, p_visit_no, NULL, p_icd_code, p_description, p_diagnosed_at)
  RETURNING diagnosis_no INTO new_no;
  RETURN new_no;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_create_prescription(
  p_appointment_id BIGINT,
  p_visit_no INT,
  p_doctor_id BIGINT,
  p_notes TEXT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
  new_no INT;
BEGIN
  INSERT INTO prescription (appointment_id, visit_no, rx_no, doctor_id, notes)
  VALUES (p_appointment_id, p_visit_no, NULL, p_doctor_id, p_notes)
  RETURNING rx_no INTO new_no;
  RETURN new_no;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_prescription_item(
  p_appointment_id BIGINT,
  p_visit_no INT,
  p_rx_no INT,
  p_med_id BIGINT,
  p_dosage VARCHAR,
  p_frequency VARCHAR,
  p_duration_days INT DEFAULT NULL,
  p_instructions TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO prescription_item (
    appointment_id, visit_no, rx_no, med_id,
    dosage, frequency, duration_days, instructions
  )
  VALUES (
    p_appointment_id, p_visit_no, p_rx_no, p_med_id,
    p_dosage, p_frequency, p_duration_days, p_instructions
  );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_create_lab_order(
  p_appointment_id BIGINT,
  p_visit_no INT,
  p_test_name VARCHAR,
  p_ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
RETURNS INT AS $$
DECLARE
  new_no INT;
BEGIN
  INSERT INTO lab_order (appointment_id, visit_no, lab_order_no, test_name, status, ordered_at)
  VALUES (p_appointment_id, p_visit_no, NULL, p_test_name, 'Ordered', p_ordered_at)
  RETURNING lab_order_no INTO new_no;
  RETURN new_no;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_record_lab_result(
  p_appointment_id BIGINT,
  p_visit_no INT,
  p_lab_order_no INT,
  p_result_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  p_result_text TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE lab_order
  SET status = 'Completed',
      result_date = p_result_date,
      result_text = p_result_text
  WHERE appointment_id = p_appointment_id
    AND visit_no = p_visit_no
    AND lab_order_no = p_lab_order_no;
END;
$$ LANGUAGE plpgsql;
