/*
A flattened source of customers
*/

with geography as (
    Select * from {{ ref('customer_geography') }}
)

select
customer.id,
customer.user_name,
customer.first_name,
customer.last_name,
customer.is_administrator,
geography.postcode
from customer
left outer join geography
on customer.id = geography.customer_id
