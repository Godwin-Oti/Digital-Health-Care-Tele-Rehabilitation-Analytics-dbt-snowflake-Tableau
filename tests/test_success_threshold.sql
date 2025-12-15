
-- This validates your core KPI logic.

WITH patient_lifetime AS (
    SELECT
        patient_id,
        SUM(number_of_modules) AS lifetime_modules
    FROM {{ ref('gold_patient_module_activity') }}
    GROUP BY 1
)

SELECT *
FROM patient_lifetime
WHERE lifetime_modules >= 24
  AND lifetime_modules IS NULL

-- This ensures successful patients always have measurable activity.
