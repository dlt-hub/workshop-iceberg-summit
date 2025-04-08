/* Table: stores */
{{
    config(
        materialized='incremental'
    )
}}
SELECT
    t.id,
    t.name,
    t.opened_at,
    t.tax_rate,
    t._dlt_load_id,
    t._dlt_id,
FROM  {{ ref('stg_stores') }} as t