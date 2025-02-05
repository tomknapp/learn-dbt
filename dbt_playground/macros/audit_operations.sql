{% macro insert_audit(action_name) %}

    insert into {{ source("postgres_example_db", "audit") }} (audit_type)
    values ('{{ action_name }}');

    commit;
{% endmacro %}
