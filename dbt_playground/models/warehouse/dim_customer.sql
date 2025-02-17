-- Example of a Type 2 Slowly Changing Dimension (SCD) model (Kimball Method 1)
{{
    config(
        materialized="incremental",
        unique_key=["customer_nkey", "valid_from"],
        incremental_strategy="merge"
    )
}}

with source_customer as (
    Select *,
        'legacy' as source_system,
        GREATEST(date_created, date_modified) as recency_date,
        CURRENT_USER as last_updated_by,
        NOW() as warehouse_created_date
    from {{ source("postgres_example_staging", "customer") }}
    {% if is_incremental() %}
    WHERE GREATEST(date_created, date_modified) > (SELECT max(GREATEST(date_created, date_modified))
    FROM {{ this }})
    {% endif %}
),

standardised_customer as (
    Select
        -- Natural and Surrogate Keys
        {{
            dbt_utils.generate_surrogate_key(
                ["source_system", "id"]
            )
        }} as customer_nkey,
        {{
            dbt_utils.generate_surrogate_key(
                ["source_system", "id", "recency_date"]
            )
        }} as customer_skey,
        -- Source fields
        *
        -- Standardise the data e.g. phonetic encoding, address standardisation, etc.
    from    source_customer
),

{% if is_incremental() %}
existing_records as (
    select customer_nkey,
        max(valid_from) as valid_from,
        max(valid_to) as valid_to
    from {{ this }}
    group by customer_nkey
),

records_to_update as (
    -- Find existing records that need their valid_to updated
    select
        er.customer_nkey,
        er.valid_from,
        sc.recency_date as new_valid_to
    from existing_records er
    inner join standardised_customer sc
        on er.customer_nkey = sc.customer_nkey
        and er.valid_to = '9999-12-31 00:00:00.000'::timestamptz
        and er.valid_from < sc.recency_date
),
{% endif %}

scd_data AS (
    SELECT
        sc.*,
        sc.recency_date as valid_from,
        COALESCE(
            LEAD(sc.recency_date) OVER (
                PARTITION BY sc.customer_nkey
                ORDER BY sc.recency_date
            ),
            '9999-12-31 00:00:00.000'::timestamptz
        ) as valid_to,
        current_timestamp as warehouse_modified_date
    FROM standardised_customer sc
)

    select
        customer_nkey,
        customer_skey,
        id,
        user_name,
        first_name,
        last_name,
        std_first_name,
        std_last_name,
        hashed_password,
        is_disabled,
        is_administrator,
        date_created,
        date_modified,
        source_system,
        recency_date,
        last_updated_by,
        valid_from,
        valid_to,
        warehouse_created_date,
        warehouse_modified_date
    from scd_data
{% if is_incremental() %}
    union all
    -- Update existing records with new valid_to dates
    select
        t.customer_nkey,
        t.customer_skey,
        t.id,
        t.user_name,
        t.first_name,
        t.last_name,
        t.std_first_name,
        t.std_last_name,
        t.hashed_password,
        t.is_disabled,
        t.is_administrator,
        t.date_created,
        t.date_modified,
        t.source_system,
        t.recency_date,
        t.last_updated_by,
        t.valid_from,
        rtu.new_valid_to as valid_to,
        t.warehouse_created_date,
        t.warehouse_modified_date
    from {{ this }} t
    inner join records_to_update rtu
        on t.customer_nkey = rtu.customer_nkey
        and t.valid_from = rtu.valid_from
{% endif %}
