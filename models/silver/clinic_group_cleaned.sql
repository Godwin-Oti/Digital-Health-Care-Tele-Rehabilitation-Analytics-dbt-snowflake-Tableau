{{ config(materialized='view') }}

SELECT
    TRIM(clinic_id) AS clinic_id,
    CASE 
        WHEN TRIM(clinic_group) IS NULL OR clinic_group = '' THEN 'Unknown Group'
        ELSE INITCAP(TRIM(clinic_group))
    END AS clinic_group
FROM {{ ref('clinic_group_raw') }}
