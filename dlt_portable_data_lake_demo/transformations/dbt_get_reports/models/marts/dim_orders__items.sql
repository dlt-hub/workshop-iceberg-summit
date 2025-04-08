with

order_items as (

    select * from {{ ref('stg_orders__items') }}

),


orders as (

    select * from {{ ref('stg_orders') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

supplies as (

    select * from {{ ref('stg_supplies') }}

),

order_supplies_summary as (

    select
        sku,

        sum(cost) as supply_cost

    from supplies

    group by 1

),

joined as (

    select
        order_items.*,

        orders.ordered_at,

        products.product_name,
        products.product_price,

        order_supplies_summary.supply_cost

    from order_items

    left join orders on order_items.order_id = orders.order_id

    left join products on order_items.sku = products.sku

    left join order_supplies_summary
        on order_items.sku = order_supplies_summary.sku

)

select * from joined