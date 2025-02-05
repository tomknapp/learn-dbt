with source_address as (
    Select * from {{ source("postgres_example_db", "address") }}
),

-- From the seeds country csv loaded using 'dbt seeds'
country as (
    Select * from {{ ref("country") }}
),

final as (

    Select
        id,
        customer_id,
        postcode,
        date_modified,
        country.country = '{{ var("best_country") }}' as best_country
    from
        source_address
    left outer join country
        on source_address.postcode = country.post_area  -- to update
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
