/* Table: supplies */
{{
    config(
        materialized='view'
    )
}}
-- depends_on: {{ ref('dlt_active_load_ids') }}

SELECT
/* select which columns will be available for table 'supplies' */
    id,
    name,
    cost::integer as cost,
    perishable,
    sku,
    _dlt_load_id,
    _dlt_id,
FROM {{ source('raw_data', 'supplies') }}

/* we only load table items of the currently active load ids into the staging table */
WHERE _dlt_load_id IN ( SELECT load_id FROM  {{ ref('dlt_active_load_ids') }} )