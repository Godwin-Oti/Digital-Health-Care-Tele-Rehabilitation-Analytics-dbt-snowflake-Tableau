{{ config(materialized='view') }}

SELECT
    patient_id,
    completion_date,
    number_of_modules
FROM {{ source('RAW_DATA', 'MODULES_RAW') }}
