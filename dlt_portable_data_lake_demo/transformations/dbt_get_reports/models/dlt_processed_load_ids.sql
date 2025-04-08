{{
    config(
        materialized='incremental'
    )
}}
-- depends_on: {{ ref('dim__dlt_loads') }}
-- depends_on: {{ ref('dim_customers') }}
-- depends_on: {{ ref('dim_items') }}
-- depends_on: {{ ref('dim_products') }}
-- depends_on: {{ ref('dim_supplies') }}
-- depends_on: {{ ref('dim_stores') }}
-- depends_on: {{ ref('dim_orders') }}
-- depends_on: {{ ref('dim_orders__items') }}
/* we save all currently active load ids into the processed ids table */
select load_id, {{ current_timestamp() }} as inserted_at FROM {{ ref('dlt_active_load_ids') }}