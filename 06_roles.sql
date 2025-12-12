DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_receptionist') THEN
    CREATE ROLE role_receptionist;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_doctor') THEN
    CREATE ROLE role_doctor;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_admin') THEN
    CREATE ROLE role_admin;
  END IF;
END
$$;

GRANT USAGE ON SCHEMA public TO role_receptionist, role_doctor, role_admin;

GRANT SELECT ON person, patient, staff, doctor, department, specialty, medication TO role_receptionist;
GRANT SELECT, INSERT, UPDATE ON appointment TO role_receptionist;
GRANT SELECT, INSERT, UPDATE ON visit TO role_doctor;
GRANT SELECT, INSERT, UPDATE ON diagnosis TO role_doctor;
GRANT SELECT, INSERT, UPDATE ON prescription TO role_doctor;
GRANT SELECT, INSERT, UPDATE ON prescription_item TO role_doctor;
GRANT SELECT, INSERT, UPDATE ON lab_order TO role_doctor;
GRANT SELECT ON appointment, person, patient, doctor, department, specialty, medication TO role_doctor;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_admin;

GRANT EXECUTE ON FUNCTION
  sp_book_appointment(BIGINT,BIGINT,TIMESTAMP,TIMESTAMP),
  sp_reschedule_appointment(BIGINT,TIMESTAMP,TIMESTAMP),
  sp_cancel_appointment(BIGINT),
  sp_mark_no_show(BIGINT),
  sp_check_in(BIGINT,TIMESTAMP),
  sp_complete_appointment(BIGINT),
  sp_add_visit_note(BIGINT,INT,TEXT,TEXT,TIMESTAMP,TIMESTAMP),
  sp_add_diagnosis(BIGINT,INT,VARCHAR,TEXT,TIMESTAMP),
  sp_create_prescription(BIGINT,INT,BIGINT,TEXT),
  sp_add_prescription_item(BIGINT,INT,INT,BIGINT,VARCHAR,VARCHAR,INT,TEXT),
  sp_create_lab_order(BIGINT,INT,VARCHAR,TIMESTAMP),
  sp_record_lab_result(BIGINT,INT,INT,TIMESTAMP,TEXT)
TO role_receptionist, role_doctor, role_admin;
