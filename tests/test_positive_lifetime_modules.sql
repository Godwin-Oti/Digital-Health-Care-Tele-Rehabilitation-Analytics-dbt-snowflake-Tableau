
-- Rule: No patient can have negative or zero lifetime modules
SELECT
    patient_id,
    SUM(number_of_modules) AS lifetime_modules
FROM {{ ref('gold_patient_module_activity') }}
GROUP BY 1
HAVING SUM(number_of_modules) <= 0


-- ✔️ Expected result: zero rows
-- ❌ If rows appear → test fails
