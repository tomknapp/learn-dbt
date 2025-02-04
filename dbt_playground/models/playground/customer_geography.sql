Select
    id,
    customer_id,
    postcode,
    date_modified
from
    public.address
where
    (customer_id, date_modified) in (
        select
            customer_id,
            max(date_modified)
        from
            public.address
        group by
            customer_id
    )
