
CREATE TABLE department (
  department_id   BIGSERIAL PRIMARY KEY,
  name            VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS specialty (
  specialty_id    BIGSERIAL PRIMARY KEY,
  department_id   BIGINT NOT NULL REFERENCES department(department_id) ON DELETE RESTRICT,
  name            VARCHAR(80) NOT NULL,
  CONSTRAINT uq_specialty_dept_name UNIQUE (department_id, name),
  CONSTRAINT uq_specialty_id_dept UNIQUE (specialty_id, department_id)
);


CREATE TABLE person (
  person_id       BIGSERIAL PRIMARY KEY,
  first_name      VARCHAR(50) NOT NULL,
  last_name       VARCHAR(50) NOT NULL,
  date_of_birth   DATE,
  gender          VARCHAR(20),
  phone           VARCHAR(25),
  email           VARCHAR(120),
  address         VARCHAR(255),
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE patient (
  person_id       BIGINT PRIMARY KEY REFERENCES person(person_id) ON DELETE CASCADE,
  national_id     VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE staff (
  person_id       BIGINT PRIMARY KEY REFERENCES person(person_id) ON DELETE CASCADE,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  hired_at        DATE
);

CREATE TABLE doctor (
  person_id       BIGINT PRIMARY KEY REFERENCES staff(person_id) ON DELETE CASCADE,
  license_no      VARCHAR(40) NOT NULL UNIQUE,
  department_id   BIGINT NOT NULL REFERENCES department(department_id) ON DELETE RESTRICT,
  specialty_id    BIGINT NOT NULL,
  CONSTRAINT fk_doctor_specialty_department
    FOREIGN KEY (specialty_id, department_id) REFERENCES specialty(specialty_id, department_id) ON DELETE RESTRICT
);

CREATE TABLE receptionist (
  person_id       BIGINT PRIMARY KEY REFERENCES staff(person_id) ON DELETE CASCADE
);

CREATE TABLE admin (
  person_id       BIGINT PRIMARY KEY REFERENCES staff(person_id) ON DELETE CASCADE
);


CREATE TABLE appointment (
  appointment_id  BIGSERIAL PRIMARY KEY,
  patient_id      BIGINT NOT NULL REFERENCES patient(person_id) ON DELETE RESTRICT,
  doctor_id       BIGINT NOT NULL REFERENCES doctor(person_id) ON DELETE RESTRICT,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  start_time      TIMESTAMP NOT NULL,
  end_time        TIMESTAMP,
  status          VARCHAR(20) NOT NULL,
  check_in_time   TIMESTAMP
);


CREATE TABLE visit (
  appointment_id      BIGINT NOT NULL,
  visit_no            INT NOT NULL,
  created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  started_at          TIMESTAMP,
  ended_at            TIMESTAMP,
  notes               TEXT,
  diagnosis_summary   TEXT,
  PRIMARY KEY (appointment_id, visit_no),
  CONSTRAINT fk_visit_appointment
    FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id) ON DELETE CASCADE
);


CREATE TABLE diagnosis (
  appointment_id  BIGINT NOT NULL,
  visit_no        INT NOT NULL,
  diagnosis_no    INT NOT NULL,
  icd_code        VARCHAR(15),
  description     TEXT NOT NULL,
  diagnosed_at    TIMESTAMP,
  PRIMARY KEY (appointment_id, visit_no, diagnosis_no),
  CONSTRAINT fk_diagnosis_visit
    FOREIGN KEY (appointment_id, visit_no) REFERENCES visit(appointment_id, visit_no) ON DELETE CASCADE
);


CREATE TABLE lab_order (
  appointment_id  BIGINT NOT NULL,
  visit_no        INT NOT NULL,
  lab_order_no    INT NOT NULL,
  test_name       VARCHAR(120) NOT NULL,
  status          VARCHAR(20) NOT NULL,
  ordered_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  result_date     TIMESTAMP,
  result_text     TEXT,
  PRIMARY KEY (appointment_id, visit_no, lab_order_no),
  CONSTRAINT fk_lab_order_visit
    FOREIGN KEY (appointment_id, visit_no) REFERENCES visit(appointment_id, visit_no) ON DELETE CASCADE
);


CREATE TABLE prescription (
  appointment_id  BIGINT NOT NULL,
  visit_no        INT NOT NULL,
  rx_no           INT NOT NULL,
  doctor_id       BIGINT NOT NULL REFERENCES doctor(person_id) ON DELETE RESTRICT,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notes           TEXT,
  PRIMARY KEY (appointment_id, visit_no, rx_no),
  CONSTRAINT fk_prescription_visit
    FOREIGN KEY (appointment_id, visit_no) REFERENCES visit(appointment_id, visit_no) ON DELETE CASCADE
);


CREATE TABLE medication (
  med_id        BIGSERIAL PRIMARY KEY,
  name          VARCHAR(120) NOT NULL,
  form          VARCHAR(40),
  strength      VARCHAR(40),
  manufacturer  VARCHAR(120)
);


CREATE TABLE prescription_item (
  appointment_id  BIGINT NOT NULL,
  visit_no        INT NOT NULL,
  rx_no           INT NOT NULL,
  med_id          BIGINT NOT NULL REFERENCES medication(med_id) ON DELETE RESTRICT,
  dosage          VARCHAR(60) NOT NULL,
  frequency       VARCHAR(60) NOT NULL,
  duration_days   INT,
  instructions    TEXT,
  PRIMARY KEY (appointment_id, visit_no, rx_no, med_id),
  CONSTRAINT fk_prescription_item_prescription
    FOREIGN KEY (appointment_id, visit_no, rx_no) REFERENCES prescription(appointment_id, visit_no, rx_no) ON DELETE CASCADE
);
