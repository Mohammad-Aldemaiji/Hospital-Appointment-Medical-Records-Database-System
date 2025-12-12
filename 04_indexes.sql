CREATE INDEX IF NOT EXISTS idx_appointment_doctor_start_time ON appointment (doctor_id, start_time);
CREATE INDEX IF NOT EXISTS idx_appointment_patient_start_time ON appointment (patient_id, start_time);
CREATE INDEX IF NOT EXISTS idx_appointment_status ON appointment (status);
CREATE INDEX IF NOT EXISTS idx_visit_created_at ON visit (created_at);
CREATE INDEX IF NOT EXISTS idx_diagnosis_icd_code ON diagnosis (icd_code);
CREATE INDEX IF NOT EXISTS idx_lab_order_test_name ON lab_order (test_name);
CREATE INDEX IF NOT EXISTS idx_prescription_doctor ON prescription (doctor_id);
CREATE INDEX IF NOT EXISTS idx_prescription_item_med ON prescription_item (med_id);
