--liquibase formatted sql
--changeset tomknapp:20250203-1-create-customer.sql
CREATE TABLE staging.customer (
    id integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    user_name text NOT NULL,
    first_name text NULL,
    last_name text NULL,
    std_first_name text NULL,
    std_last_name text NULL,
    hashed_password text NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    is_administrator boolean NOT NULL DEFAULT false,
    date_created timestamp
    with
        time zone NOT NULL DEFAULT now (),
        date_modified timestamp
    with
        time zone NOT NULL DEFAULT now ()
);

ALTER TABLE staging.customer ADD CONSTRAINT user_pkey PRIMARY KEY (id);

--rollback DROP TABLE staging.customer;
