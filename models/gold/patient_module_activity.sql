{{ config(materialized='table') }}

SELECT
    cwp.patient_id,
    cwp.clinic_id,
    cwp.clinic_title,
    cg.clinic_group,
    cwp.patient_created_at_date,
    m.module_completion_date,
    m.number_of_modules
FROM {{ ref('clinics_with_patients_cleaned') }} cwp
JOIN {{ ref('clinic_group_cleaned') }} cg
    ON cwp.clinic_id = cg.clinic_id
JOIN {{ ref('modules_cleaned') }} m
    ON cwp.patient_id = m.patient_id
