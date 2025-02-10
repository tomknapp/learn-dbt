--liquibase formatted sql
--changeset tomknapp:20250210-1-create-ons-postcode.sql
--varchar for max length constraints
CREATE TABLE staging.ons_postcode (
    postcode VARCHAR(8) NOT NULL,
    positional_quality_indicator INTEGER,
    eastings INTEGER,
    northings INTEGER,
    country_code VARCHAR(9),
    nhs_regional_ha_code VARCHAR(9),
    nhs_ha_code VARCHAR(9),
    admin_county_code VARCHAR(9),
    admin_district_code VARCHAR(9),
    admin_ward_code VARCHAR(9),
    created_date timestamp
    with
        time zone NOT NULL DEFAULT now ()
);

ALTER TABLE staging.ons_postcode ADD CONSTRAINT ons_postcode_pkey PRIMARY KEY (postcode);

--rollback DROP TABLE staging.ons_postcode;
