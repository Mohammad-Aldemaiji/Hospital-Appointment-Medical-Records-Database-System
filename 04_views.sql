CREATE OR REPLACE VIEW v_doctor_schedule AS
SELECT
  a.appointment_id,
  a.start_time,
  a.end_time,
  a.status,
  a.patient_id,
  a.doctor_id,
  (dp.first_name || ' ' || dp.last_name) AS doctor_name,
  (pp.first_name || ' ' || pp.last_name) AS patient_name,
  d.department_id,
  dep.name AS department_name,
  d.specialty_id,
  sp.name AS specialty_name
FROM appointment a
JOIN doctor d ON d.person_id = a.doctor_id
JOIN person dp ON dp.person_id = d.person_id
JOIN patient pat ON pat.person_id = a.patient_id
JOIN person pp ON pp.person_id = pat.person_id
JOIN department dep ON dep.department_id = d.department_id
JOIN specialty sp ON sp.specialty_id = d.specialty_id;

CREATE OR REPLACE VIEW v_doctor_daily_counts AS
SELECT
  a.doctor_id,
  (dp.first_name || ' ' || dp.last_name) AS doctor_name,
  date_trunc('day', a.start_time) AS day,
  COUNT(*) AS total_appointments,
  COUNT(*) FILTER (WHERE a.status = 'Scheduled') AS scheduled_count,
  COUNT(*) FILTER (WHERE a.status = 'Completed') AS completed_count,
  COUNT(*) FILTER (WHERE a.status = 'Canceled') AS canceled_count,
  COUNT(*) FILTER (WHERE a.status = 'NoShow') AS noshow_count
FROM appointment a
JOIN doctor d ON d.person_id = a.doctor_id
JOIN person dp ON dp.person_id = d.person_id
GROUP BY a.doctor_id, doctor_name, date_trunc('day', a.start_time);

CREATE OR REPLACE VIEW v_no_show_rate_monthly AS
SELECT
  date_trunc('month', a.start_time) AS month,
  d.department_id,
  dep.name AS department_name,
  a.doctor_id,
  (dp.first_name || ' ' || dp.last_name) AS doctor_name,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE a.status = 'NoShow') AS noshows,
  ROUND(
    (COUNT(*) FILTER (WHERE a.status = 'NoShow')::NUMERIC / NULLIF(COUNT(*),0)) * 100,
    2
  ) AS no_show_rate_percent
FROM appointment a
JOIN doctor d ON d.person_id = a.doctor_id
JOIN person dp ON dp.person_id = d.person_id
JOIN department dep ON dep.department_id = d.department_id
GROUP BY month, d.department_id, dep.name, a.doctor_id, doctor_name;

CREATE OR REPLACE VIEW v_busiest_hours AS
SELECT
  EXTRACT(HOUR FROM a.start_time)::INT AS hour_of_day,
  COUNT(*) AS total_appointments,
  COUNT(*) FILTER (WHERE a.status = 'Completed') AS completed_appointments
FROM appointment a
GROUP BY EXTRACT(HOUR FROM a.start_time)::INT
ORDER BY hour_of_day;

CREATE OR REPLACE VIEW v_appointment_lead_time_minutes AS
SELECT
  a.appointment_id,
  a.patient_id,
  a.doctor_id,
  a.created_at,
  a.start_time,
  ROUND(EXTRACT(EPOCH FROM (a.start_time - a.created_at)) / 60.0, 2) AS lead_time_minutes
FROM appointment a
WHERE a.start_time IS NOT NULL AND a.created_at IS NOT NULL;

CREATE OR REPLACE VIEW v_patient_visit_history AS
SELECT
  ap.patient_id,
  (pp.first_name || ' ' || pp.last_name) AS patient_name,
  v.appointment_id,
  v.visit_no,
  v.created_at AS visit_created_at,
  ap.doctor_id,
  (dp.first_name || ' ' || dp.last_name) AS doctor_name,
  dep.name AS department_name,
  sp.name AS specialty_name
FROM visit v
JOIN appointment ap ON ap.appointment_id = v.appointment_id
JOIN patient pat ON pat.person_id = ap.patient_id
JOIN person pp ON pp.person_id = pat.person_id
JOIN doctor d ON d.person_id = ap.doctor_id
JOIN person dp ON dp.person_id = d.person_id
JOIN department dep ON dep.department_id = d.department_id
JOIN specialty sp ON sp.specialty_id = d.specialty_id;

CREATE OR REPLACE VIEW v_patient_revisit_30d AS
WITH visits AS (
  SELECT
    ap.patient_id,
    v.appointment_id,
    v.visit_no,
    v.created_at AS visit_time,
    LAG(v.created_at) OVER (PARTITION BY ap.patient_id ORDER BY v.created_at) AS prev_visit_time
  FROM visit v
  JOIN appointment ap ON ap.appointment_id = v.appointment_id
)
SELECT
  patient_id,
  COUNT(*) AS total_visits,
  COUNT(*) FILTER (
    WHERE prev_visit_time IS NOT NULL
      AND visit_time - prev_visit_time <= INTERVAL '30 days'
  ) AS revisits_within_30d,
  ROUND(
    (COUNT(*) FILTER (
      WHERE prev_visit_time IS NOT NULL
        AND visit_time - prev_visit_time <= INTERVAL '30 days'
    )::NUMERIC / NULLIF(COUNT(*)-1,0)) * 100,
    2
  ) AS revisit_rate_percent
FROM visits
GROUP BY patient_id;

CREATE OR REPLACE VIEW v_top_diagnoses_monthly AS
SELECT
  date_trunc('month', v.created_at) AS month,
  d.icd_code,
  COALESCE(d.icd_code, 'UNKNOWN') AS icd_code_group,
  d.description,
  COUNT(*) AS diagnosis_count
FROM diagnosis d
JOIN visit v ON v.appointment_id = d.appointment_id AND v.visit_no = d.visit_no
GROUP BY month, d.icd_code, icd_code_group, d.description
ORDER BY month, diagnosis_count DESC;

CREATE OR REPLACE VIEW v_prescription_medication_counts AS
SELECT
  p.appointment_id,
  p.visit_no,
  p.rx_no,
  p.doctor_id,
  COUNT(pi.med_id) AS medication_count
FROM prescription p
LEFT JOIN prescription_item pi
  ON pi.appointment_id = p.appointment_id
 AND pi.visit_no = p.visit_no
 AND pi.rx_no = p.rx_no
GROUP BY p.appointment_id, p.visit_no, p.rx_no, p.doctor_id;

CREATE OR REPLACE VIEW v_top_medications AS
SELECT
  m.med_id,
  m.name,
  m.form,
  m.strength,
  COUNT(*) AS times_prescribed
FROM prescription_item pi
JOIN medication m ON m.med_id = pi.med_id
GROUP BY m.med_id, m.name, m.form, m.strength
ORDER BY times_prescribed DESC;

CREATE OR REPLACE VIEW v_lab_turnaround_minutes AS
SELECT
  lo.appointment_id,
  lo.visit_no,
  lo.lab_order_no,
  lo.test_name,
  lo.status,
  lo.ordered_at,
  lo.result_date,
  CASE
    WHEN lo.result_date IS NULL THEN NULL
    ELSE ROUND(EXTRACT(EPOCH FROM (lo.result_date - lo.ordered_at)) / 60.0, 2)
  END AS turnaround_minutes
FROM lab_order lo;
