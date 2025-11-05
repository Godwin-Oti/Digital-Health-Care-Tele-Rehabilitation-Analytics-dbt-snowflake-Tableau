{{ config(materialized='view') }}

SELECT
    CAST(patient_id AS INT) AS patient_id,
    clinic_title,
    clinic_id,
    created_at,
    deleted_at
FROM {{ source('RAW_DATA', 'CLINICS_WITH_PATIENTS_RAW') }}
