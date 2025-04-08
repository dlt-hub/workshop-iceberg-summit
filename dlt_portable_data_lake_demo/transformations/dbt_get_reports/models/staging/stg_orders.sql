/* Table: orders */
{{
    config(
        materialized='view'
    )
}}
-- depends_on: {{ ref('dlt_active_load_ids') }}

SELECT
/* select which columns will be available for table 'orders' */
    id as order_id,
    customer_id,
    store_id,
    ordered_at,
    subtotal::integer as subtotal,
    tax_paid:: integer as tax_paid,
    order_total,
    _dlt_load_id,
    _dlt_id,
FROM {{ source('raw_data', 'orders') }}

/* we only load table items of the currently active load ids into the staging table */
WHERE _dlt_load_id IN ( SELECT load_id FROM  {{ ref('dlt_active_load_ids') }} )