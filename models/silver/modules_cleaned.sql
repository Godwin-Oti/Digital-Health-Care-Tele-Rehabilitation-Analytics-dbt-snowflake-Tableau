{{ config(materialized='view') }}

SELECT
    CAST(patient_id AS INT) AS patient_id,
    TRY_TO_DATE(completion_date, 'DD/MM/YYYY') AS module_completion_date,
    CAST(number_of_modules AS INT) AS number_of_modules
FROM {{ ref('modules_raw') }}
WHERE number_of_modules > 0
  AND completion_date IS NOT NULL
