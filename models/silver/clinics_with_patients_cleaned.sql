{{ config(materialized='view') }}

SELECT
    CAST(patient_id AS INT) AS patient_id,
    INITCAP(TRIM(clinic_title)) AS clinic_title,
    TRIM(clinic_id) AS clinic_id,
    TRY_TO_DATE(created_at, 'DD/MM/YYYY') AS patient_created_at_date,
    TRY_TO_DATE(NULLIF(deleted_at, ''), 'DD/MM/YYYY') AS patient_deleted_at
FROM {{ ref('clinics_with_patients_raw') }}
WHERE patient_id IS NOT NULL
