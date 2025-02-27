# dbt and Airflow Playground

Provides a dockerised environment and an initial database schema and data to
play around with **d**ata **b**uild **t**ool and Apache Airflow.

A postgres database container is created by the docker compose file.

Database setup is performed on startup by applying database migrations to
create the schema and populate it with faked data.

Liquibase is used as the database migration tool and is created as a docker
container that runs against the database, conditional on the database reaching
a healthy state.

## dbt

dbt provides functionality to transform data for analysis or consumption.
It is generally used for the **T**ransform part of **ELT** pipelines.

## Airflow

Apache Airflow provides batch workflow functionality including scheduling
and monitoring. **E**xtract and **L**oad pipelines can be written and run
in Airflow to provide the source data to be **T**ransformed by **dbt**.

## Setup

### [mise-en-place](https://mise.jdx.dev) dev tool

The repo contains a .mise.toml file for use with [mise-en-place](https://mise.jdx.dev)

mise cli can be installed in multiple ways, summarised [here](https://mise.jdx.dev/getting-started.html)

e.g. with homebrew:

```zsh
brew install mise
```

After installation, you can configure your shell to automatically [activate](https://mise.jdx.dev/getting-started.html#activate-mise) mise
when you cd into a directory containing a .mise.toml file by adding the following to your shell configuration file (e.g. ~/.zshrc or ~/.bashrc):

```zsh
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

After installation, you can install the required runtimes, create and activate a python virtual environment,
and install the required python packages by running:

```zsh
mise install
```

The first time you run mise in the directory, you will be promted to trust the .mise.toml file. This will allow mise to automatically
activate the virtual environment when you cd into the directory.

### Environment variables

Create a .env file in the project root directory based on the .env_example

Generate a (connection parameter compatible) secure password:

```zsh
openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c 64
```

### Docker Compose

Setup the docker environment by first building the containers contained
in the docker-compose.yml file.

```zsh
docker compose build
```

Startup the docker environmement to create the database, run the initial
liquibase migrations and setup Airflow.

```zsh
docker compose up -d
```

### Setup dbt

dbt commands can be run within the dbt_playground directory to debug, test
and run models.

Create the profile for dbt to use to connect to the source database.

If you haven't installed dbt previously, create a .dbt folder in your home
directory and create a profiles.yml file:

```zsh
cd ~
mkdir .dbt
cd .dbt
touch profiles.yml
```

Add a profile for the dbt-playground to the profiles.yml file:

```yaml
dbt_playground:
  outputs:
    dev:
      dbname: <DB_NAME from your .env file>
      host: localhost
      pass: <DB_PASSWORD from your .env file>
      port: 5432
      schema: dbt
      threads: 1
      type: postgres
      user: <DB_USER from your .env file>
  target: dev
```

From the learn-dbt project directory, change into the dbt_playground
directory:

```zsh
cd dbt_playground
```

Test the setup and database connection by running:

```zsh
dbt debug
```

Install the dbt dependencies:

```zsh
dbt deps
```

Load the seed data:

```zsh
dbt seed
```

Run the dbt models:

```zsh
dbt run
```

Build the documentation:

```zsh
dbt docs generate
```

View the documentation (when Airflow isn't running due to port conflict):

```zsh
dbt docs serve
```

## Using the playground

Some example usage

### Using Airflow

When the docker environment is running, the Airflow UI can be
accessed at: [http://localhost:8080](http://localhost:8080)

Sign in with username: **airflow**, password: **airflow**

Create a database connection for the example ons_postcode_pipeline.py
to use:

- Navigate to Admin > [Connections](http://localhost:8080/connection/list/)
- Add a new connection of type postgres
- Enter the connection_id as "postgres_dag_connection" to match
  the one set in the ons_postcode_pipeline.py file
- Use the connection parameters from the project .env file
