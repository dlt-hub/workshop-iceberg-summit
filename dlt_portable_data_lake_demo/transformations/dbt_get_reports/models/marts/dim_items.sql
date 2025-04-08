/* Table: items */
{{
    config(
        materialized='incremental'
    )
}}
SELECT
    t.id,
    t.order_id,
    t.sku,
    t._dlt_load_id,
    t._dlt_id,
FROM  {{ ref('stg_items') }} as t