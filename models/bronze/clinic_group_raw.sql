{{ config(materialized='view') }}

SELECT
    clinic_id,
    clinic_group
FROM {{ source('RAW_DATA', 'CLINIC_GROUP_RAW') }}
