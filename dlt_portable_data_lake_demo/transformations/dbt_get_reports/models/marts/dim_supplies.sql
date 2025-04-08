/* Table: supplies */
{{
    config(
        materialized='incremental'
    )
}}
SELECT
    t.id,
    t.name,
    t.cost,
    t.perishable,
    t.sku,
    t._dlt_load_id,
    t._dlt_id,
FROM  {{ ref('stg_supplies') }} as t

