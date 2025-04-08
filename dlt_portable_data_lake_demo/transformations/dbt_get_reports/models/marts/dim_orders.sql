{{
    config(
        materialized='incremental'
    )
}}

with

orders as (

    select * from {{ ref('stg_orders') }}

),

order_items as (

    select * from {{ ref('dim_orders__items') }}

),

order_items_summary as (

    select
        order_id,

        sum(supply_cost) as order_cost,
        sum(product_price) as order_items_subtotal,
        count(order_item_id) as count_order_items,

    from order_items

    group by 1

),

compute_booleans as (

    select
        orders.*,

        order_items_summary.order_cost,
        order_items_summary.order_items_subtotal,
        order_items_summary.count_order_items,

    from orders

    left join
        order_items_summary
        on orders.order_id = order_items_summary.order_id

),

customer_order_count as (

    select
        *,

        row_number() over (
            partition by customer_id
            order by ordered_at asc
        ) as customer_order_number

    from compute_booleans

)

select * from customer_order_count
