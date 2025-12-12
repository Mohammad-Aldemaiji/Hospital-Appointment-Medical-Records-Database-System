BEGIN;

INSERT INTO department (department_id, name) VALUES
(1,'Cardiology'),
(2,'Internal Medicine'),
(3,'Pediatrics'),
(4,'Emergency');

INSERT INTO specialty (specialty_id, department_id, name) VALUES
(10,1,'General Cardiology'),
(11,1,'Interventional Cardiology'),
(12,2,'Endocrinology'),
(13,2,'Gastroenterology'),
(14,3,'General Pediatrics'),
(15,3,'Pediatric Neurology'),
(16,4,'Emergency Medicine'),
(17,4,'Trauma Care');

INSERT INTO person (person_id, first_name, last_name, date_of_birth, gender, phone, email, address, created_at) VALUES
(100,'Amina','Alharbi','2002-03-14','F','+966500001001','amina.alharbi@example.test','Riyadh','2025-01-10 09:00:00'),
(101,'Fahad','Alotaibi','1998-11-02','M','+966500001002','fahad.alotaibi@example.test','Riyadh','2025-01-10 09:00:00'),
(102,'Sara','Alqahtani','2004-07-22','F','+966500001003','sara.alqahtani@example.test','Riyadh','2025-01-10 09:00:00'),
(103,'Nasser','Alghamdi','1995-01-30','M','+966500001004','nasser.alghamdi@example.test','Riyadh','2025-01-10 09:00:00'),
(104,'Laila','Almutairi','2001-12-09','F','+966500001005','laila.almutairi@example.test','Riyadh','2025-01-10 09:00:00'),
(105,'Yousef','Alshehri','1999-05-18','M','+966500001006','yousef.alshehri@example.test','Riyadh','2025-01-10 09:00:00'),
(200,'Hassan','Alshammari','1984-02-12','M','+966500002001','hassan.alshammari@example.test','Riyadh','2025-01-10 09:00:00'),
(201,'Reem','Alzahrani','1989-06-03','F','+966500002002','reem.alzahrani@example.test','Riyadh','2025-01-10 09:00:00'),
(202,'Majed','Alsubaie','1978-09-26','M','+966500002003','majed.alsubaie@example.test','Riyadh','2025-01-10 09:00:00'),
(203,'Noor','Almalki','1992-04-07','F','+966500002004','noor.almalki@example.test','Riyadh','2025-01-10 09:00:00'),
(204,'Omar','Alenazi','1986-10-15','M','+966500002005','omar.alenazi@example.test','Riyadh','2025-01-10 09:00:00');

INSERT INTO patient (person_id, national_id) VALUES
(100,'P-1000001'),
(101,'P-1000002'),
(102,'P-1000003'),
(103,'P-1000004'),
(104,'P-1000005'),
(105,'P-1000006');

INSERT INTO staff (person_id, is_active, hired_at) VALUES
(200,TRUE,'2018-01-10'),
(201,TRUE,'2017-05-21'),
(202,TRUE,'2015-09-01'),
(203,TRUE,'2020-02-14'),
(204,TRUE,'2019-11-05');

INSERT INTO doctor (person_id, license_no, department_id, specialty_id) VALUES
(200,'D-1001',2,12),
(201,'D-1002',1,10),
(202,'D-1003',4,16);

INSERT INTO receptionist (person_id) VALUES
(203);

INSERT INTO admin (person_id) VALUES
(204);

INSERT INTO medication (med_id, name, form, strength, manufacturer) VALUES
(500,'Amoxicillin','Capsule','500mg','Generic'),
(501,'Azithromycin','Tablet','250mg','Generic'),
(502,'Metformin','Tablet','500mg','Generic'),
(503,'Atorvastatin','Tablet','20mg','Generic'),
(504,'Lisinopril','Tablet','10mg','Generic'),
(505,'Amlodipine','Tablet','5mg','Generic'),
(506,'Omeprazole','Capsule','20mg','Generic'),
(507,'Ibuprofen','Tablet','400mg','Generic'),
(508,'Paracetamol','Tablet','500mg','Generic'),
(509,'Salbutamol','Inhaler','100mcg','Generic'),
(510,'Cetirizine','Tablet','10mg','Generic'),
(511,'Prednisolone','Tablet','5mg','Generic'),
(512,'Insulin Glargine','Injection','100U/mL','Generic'),
(513,'Clopidogrel','Tablet','75mg','Generic'),
(514,'Aspirin','Tablet','81mg','Generic'),
(515,'Hydrochlorothiazide','Tablet','25mg','Generic'),
(516,'Levothyroxine','Tablet','50mcg','Generic'),
(517,'Losartan','Tablet','50mg','Generic'),
(518,'Pantoprazole','Tablet','40mg','Generic'),
(519,'Doxycycline','Capsule','100mg','Generic');

INSERT INTO appointment (appointment_id, patient_id, doctor_id, created_at, start_time, end_time, status, check_in_time)
SELECT
  gs AS appointment_id,
  (100 + ((gs - 1001) % 6))::BIGINT AS patient_id,
  (200 + ((gs - 1001) % 3))::BIGINT AS doctor_id,
  (TIMESTAMP '2025-02-01 08:00:00' + ((gs - 1001) * INTERVAL '3 hours')) AS created_at,
  (TIMESTAMP '2025-02-10 08:00:00' + ((gs - 1001) * INTERVAL '1 hour')) AS start_time,
  (TIMESTAMP '2025-02-10 08:30:00' + ((gs - 1001) * INTERVAL '1 hour')) AS end_time,
  CASE
    WHEN (gs % 5) = 0 THEN 'Completed'
    WHEN (gs % 9) = 0 THEN 'NoShow'
    WHEN (gs % 7) = 0 THEN 'Canceled'
    ELSE 'Scheduled'
  END AS status,
  CASE
    WHEN (gs % 5) = 0 THEN (TIMESTAMP '2025-02-10 07:55:00' + ((gs - 1001) * INTERVAL '1 hour'))
    ELSE NULL
  END AS check_in_time
FROM generate_series(1001,1060) AS gs;

INSERT INTO visit (appointment_id, visit_no, created_at, started_at, ended_at, notes, diagnosis_summary)
SELECT
  a.appointment_id,
  1 AS visit_no,
  a.start_time AS created_at,
  a.start_time AS started_at,
  (a.start_time + INTERVAL '20 minutes') AS ended_at,
  'Visit created from completed appointment.' AS notes,
  'Clinical assessment recorded.' AS diagnosis_summary
FROM appointment a
WHERE a.status = 'Completed';

INSERT INTO diagnosis (appointment_id, visit_no, diagnosis_no, icd_code, description, diagnosed_at)
SELECT
  v.appointment_id,
  v.visit_no,
  d.diagnosis_no,
  CASE d.diagnosis_no
    WHEN 1 THEN 'R10.9'
    ELSE 'Z00.0'
  END AS icd_code,
  CASE d.diagnosis_no
    WHEN 1 THEN 'Abdominal pain, unspecified'
    ELSE 'General medical examination'
  END AS description,
  v.created_at + INTERVAL '5 minutes' AS diagnosed_at
FROM visit v
JOIN LATERAL (
  SELECT 1 AS diagnosis_no
  UNION ALL
  SELECT 2 AS diagnosis_no
) d ON TRUE
WHERE (v.appointment_id % 2) = 0
UNION ALL
SELECT
  v.appointment_id,
  v.visit_no,
  1 AS diagnosis_no,
  'J06.9' AS icd_code,
  'Acute upper respiratory infection, unspecified' AS description,
  v.created_at + INTERVAL '5 minutes' AS diagnosed_at
FROM visit v
WHERE (v.appointment_id % 2) = 1;

INSERT INTO prescription (appointment_id, visit_no, rx_no, doctor_id, created_at, notes)
SELECT
  v.appointment_id,
  v.visit_no,
  1 AS rx_no,
  a.doctor_id,
  v.created_at + INTERVAL '10 minutes' AS created_at,
  'Standard prescription issued during visit.' AS notes
FROM visit v
JOIN appointment a ON a.appointment_id = v.appointment_id;

INSERT INTO prescription_item (appointment_id, visit_no, rx_no, med_id, dosage, frequency, duration_days, instructions)
SELECT
  p.appointment_id,
  p.visit_no,
  p.rx_no,
  (500 + (p.appointment_id % 20))::BIGINT AS med_id,
  '1 unit' AS dosage,
  '2x/day' AS frequency,
  5 AS duration_days,
  'Take with food.' AS instructions
FROM prescription p;

INSERT INTO prescription_item (appointment_id, visit_no, rx_no, med_id, dosage, frequency, duration_days, instructions)
SELECT
  p.appointment_id,
  p.visit_no,
  p.rx_no,
  (500 + ((p.appointment_id + 7) % 20))::BIGINT AS med_id,
  '1 unit' AS dosage,
  '1x/day' AS frequency,
  7 AS duration_days,
  'Take at the same time daily.' AS instructions
FROM prescription p
WHERE (500 + ((p.appointment_id + 7) % 20))::BIGINT <> (500 + (p.appointment_id % 20))::BIGINT;

INSERT INTO lab_order (appointment_id, visit_no, lab_order_no, test_name, status, ordered_at, result_date, result_text)
SELECT
  v.appointment_id,
  v.visit_no,
  1 AS lab_order_no,
  CASE
    WHEN (v.appointment_id % 3) = 0 THEN 'CBC'
    WHEN (v.appointment_id % 3) = 1 THEN 'Blood Glucose'
    ELSE 'Lipid Panel'
  END AS test_name,
  'Completed' AS status,
  v.created_at + INTERVAL '2 minutes' AS ordered_at,
  v.created_at + INTERVAL '1 hour' AS result_date,
  'Result recorded.' AS result_text
FROM visit v;

SELECT setval(pg_get_serial_sequence('department','department_id'), (SELECT MAX(department_id) FROM department));
SELECT setval(pg_get_serial_sequence('specialty','specialty_id'), (SELECT MAX(specialty_id) FROM specialty));
SELECT setval(pg_get_serial_sequence('person','person_id'), (SELECT MAX(person_id) FROM person));
SELECT setval(pg_get_serial_sequence('appointment','appointment_id'), (SELECT MAX(appointment_id) FROM appointment));
SELECT setval(pg_get_serial_sequence('medication','med_id'), (SELECT MAX(med_id) FROM medication));

COMMIT;
