/*
A flattened source of customers
*/

with source_customers as (
    Select * from {{ source("postgres_example_db", "customer") }}
),

geography as (
    Select * from {{ ref('customer_geography') }}
),

final as (

    Select
    source_customers.id,
    source_customers.user_name,
    source_customers.first_name,
    source_customers.last_name,
    source_customers.is_administrator,
    geography.postcode
    from source_customers
    left outer join geography
    on source_customers.id = geography.customer_id
)

Select * from final
