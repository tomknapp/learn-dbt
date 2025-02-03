# DBT Playground

Provides a dockerised environment and an initial database schema and data to
play around with DBT.

## Database

A postgres database container is created by the docker compose file.

## Migrations

Database setup is performed on startup by applying database migrations to
create the schema and populate it with faked data.

### Liquibase

Liquibase is used as the database migration tool and is created as a docker
container that runs on database, conditional on the database reaching a healthy
state.

## DBT

Data transformation software

### Setup

Create the dbt project within the initial repo by running:

```zsh
dbt init dbt_playground
```

Enter the database connection details (obtained from the docker-compose.yml
file)

Change into the new project directory:

```zsh
cd dbt_playground
```

Test the setup and database connection by running:

```zsh
dbt debug
```
