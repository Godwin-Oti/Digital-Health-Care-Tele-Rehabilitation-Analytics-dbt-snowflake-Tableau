
-- Time Consistency Test
-- Flags impossible timelines
SELECT
    g.patient_id,
    g.module_completion_date,
    s.patient_created_at
FROM {{ ref('gold_patient_module_activity') }} g
JOIN {{ ref('silver_clinics_with_patients_cleaned') }} s
  ON g.patient_id = s.patient_id
WHERE g.module_completion_date < s.patient_created_at
