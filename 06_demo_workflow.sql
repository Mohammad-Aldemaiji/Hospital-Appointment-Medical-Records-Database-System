SELECT sp_book_appointment(100, 200, TIMESTAMP '2025-03-01 10:00:00', NULL) AS new_appointment_id;

SELECT sp_check_in(1001, TIMESTAMP '2025-02-10 07:55:00');

SELECT sp_complete_appointment(1001);

SELECT * FROM visit WHERE appointment_id = 1001 ORDER BY visit_no;

SELECT sp_add_visit_note(1001, 1, 'Patient reports mild headache.', 'Tension headache', TIMESTAMP '2025-02-10 08:00:00', TIMESTAMP '2025-02-10 08:20:00');

SELECT sp_add_diagnosis(1001, 1, 'G44.2', 'Tension-type headache', TIMESTAMP '2025-02-10 08:05:00') AS diagnosis_no;

SELECT sp_create_prescription(1001, 1, 200, 'Pain management') AS rx_no;

SELECT sp_add_prescription_item(1001, 1, 1, 508, '1 tablet', '2x/day', 3, 'After meals');

SELECT sp_create_lab_order(1001, 1, 'CBC', TIMESTAMP '2025-02-10 08:02:00') AS lab_order_no;

SELECT sp_record_lab_result(1001, 1, 1, TIMESTAMP '2025-02-10 09:00:00', 'All values within normal range.');

SELECT * FROM v_doctor_daily_counts ORDER BY day DESC, doctor_id;

SELECT * FROM v_top_medications LIMIT 10;
