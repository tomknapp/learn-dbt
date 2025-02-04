with source_address as (
    Select * from {{ source("postgres_example_db", "address") }}
),

final as (

    Select
        id,
        customer_id,
        postcode,
        date_modified
    from
        source_address
    where
        (customer_id, date_modified) in (
            select
                customer_id,
                max(date_modified)
            from
                source_address
            group by
                customer_id
        )
)

Select * from final
