with source_address as (
    Select * from {{ source("postgres_example_staging", "address") }}
),

standardised_address as (
    Select *,
    public.fn_valid_postcode(postcode) as valid_postcode,
    SUBSTRING(public.fn_valid_postcode(postcode) FROM '^[^0-9]*') as std_post_area
    from source_address
),

-- From the seeds country csv loaded using 'dbt seed'
country as (
    Select * from {{ ref("country_codes") }}
),

final as (

    Select
        id,
        customer_id,
        postcode,
        standardised_address.valid_postcode,
        standardised_address.std_post_area,
        country.country,
        country.country = '{{ var("best_country") }}' as best_country,
        date_modified
    from
        standardised_address
    left outer join country
        on standardised_address.std_post_area = country.post_area
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
