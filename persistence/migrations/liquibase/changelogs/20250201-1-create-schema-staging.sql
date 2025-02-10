--liquibase formatted sql
--changeset tomknapp:20250201-1-create-schema-staging.sql
CREATE SCHEMA staging
--rollback DROP SCHEMA staging;
