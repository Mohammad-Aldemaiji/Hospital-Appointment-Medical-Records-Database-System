SELECT * FROM v_doctor_daily_counts ORDER BY day DESC, doctor_id;

SELECT * FROM v_no_show_rate_monthly ORDER BY month DESC, department_name, doctor_name;

SELECT * FROM v_busiest_hours;

SELECT * FROM v_appointment_lead_time_minutes ORDER BY lead_time_minutes DESC NULLS LAST;

SELECT * FROM v_patient_revisit_30d ORDER BY revisit_rate_percent DESC NULLS LAST;

SELECT month, icd_code_group, SUM(diagnosis_count) AS total
FROM v_top_diagnoses_monthly
GROUP BY month, icd_code_group
ORDER BY month DESC, total DESC;

SELECT * FROM v_prescription_medication_counts ORDER BY medication_count DESC;

SELECT * FROM v_top_medications LIMIT 20;

SELECT
  test_name,
  COUNT(*) AS total_orders,
  AVG(turnaround_minutes) AS avg_turnaround_minutes,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY turnaround_minutes) AS median_turnaround_minutes
FROM v_lab_turnaround_minutes
WHERE turnaround_minutes IS NOT NULL
GROUP BY test_name
ORDER BY avg_turnaround_minutes DESC;

SELECT * FROM v_lab_turnaround_minutes ORDER BY turnaround_minutes DESC NULLS LAST;
