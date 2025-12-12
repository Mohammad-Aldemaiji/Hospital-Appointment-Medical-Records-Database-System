# Hospital Appointment & Medical Records Database System — Requirements

## Overview
This project is a relational database system designed to support core hospital operations including patient registration, provider management, appointment scheduling, clinical visit documentation, diagnoses, prescriptions, and lab orders. The system also includes a reporting and analytics layer to enable operational monitoring and trend analysis through SQL with Python-based visualizations.

## Objective
Design and implement a normalized hospital database with strong data integrity, consistent clinical and scheduling workflows, and a structured analytics layer (views + reports) that supports decision-making and operational insights.

## Scope (MVP)

### User roles
- **Receptionist:** manages patient records and schedules/reschedules/cancels appointments
- **Doctor:** documents visits, diagnoses, prescriptions, and lab orders
- **Administrator:** full access and system oversight

### Functional requirements (Operational)
- Maintain master data for **patients** and **doctors**
- Maintain organizational structure: **departments** and **specialties**
- Schedule and manage **appointments**
  - Support rescheduling and cancellation
  - Track appointment status: **Scheduled, Completed, Canceled, NoShow**
- Generate a **visit** record when an appointment is marked **Completed**
- Store visit documentation including **clinical notes** and **diagnosis summary**
- Support multiple **diagnoses** per visit
- Support **prescriptions** per visit with multiple medication items per prescription
- Support **lab orders** per visit with optional results and result timestamps

### Reporting and analytics requirements
Provide SQL views and reporting queries to support operational analysis, including:
- Daily doctor schedules and appointment counts
- No-show rates by doctor, department, and month
- Appointment volume trends by hour/day (capacity planning)
- Lead time analysis (appointment created → appointment start)
- Patient revisit rate within 30 days
- Diagnosis frequency and trends over time
- Prescription patterns (e.g., top medications, average medications per visit)
- Lab turnaround time (ordered → result date)

## Out of scope (current release)
- Billing and insurance processing
- Pharmacy inventory and stock control
- Imaging workflows (X-ray/MRI/CT)
- Integration with external EHR/HIS systems or real patient datasets

## Assumptions and constraints
- Each appointment links exactly **one patient** and **one doctor**
- A **visit** is created only when an appointment is marked **Completed**
- A prescription belongs to a **single visit** and may contain **multiple medications**
- Lab orders belong to a **single visit**
- Sample data used for development/testing is **synthetic** and contains no real personal or medical information

## Data fields required to enable analytics
To support reporting, the schema will include:
- `appointments.created_at`
- `appointments.start_time`, `appointments.end_time`
- (optional) `appointments.check_in_time`
- `visits.created_at`
- (optional) `visits.started_at`, `visits.ended_at`
- `lab_orders.ordered_at`, `lab_orders.result_date`

## Target entities (tables)
- patients
- doctors
- departments
- specialties
- appointments
- visits
- diagnoses
- prescriptions
- medications
- prescription_items
- lab_orders

## Quality goals
- Normalized schema to reduce redundancy and update anomalies
- Strong referential integrity (PK/FK) and domain constraints (NOT NULL, UNIQUE, CHECK)
- Clear naming conventions, consistent data types, and readable SQL
- Reproducible seed data suitable for testing and validation
- Analytics layer implemented using SQL views and report queries
