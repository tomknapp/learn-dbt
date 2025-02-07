import os
import shutil
import tempfile
import zipfile
from datetime import datetime, timedelta
from typing import Dict

import requests

from airflow.decorators import dag, task
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.utils.log.logging_mixin import LoggingMixin

logger = LoggingMixin().log

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}


@dag(
    dag_id="ons_postcode_load_taskflow",
    default_args=default_args,
    description="Download and load ONS postcode data",
    schedule_interval="@monthly",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["ons", "postcodes"],
)
def ons_postcode_pipeline():
    @task
    def download_postcode_data() -> Dict[str, str]:
        """Download postcode data from ONS website"""
        url = "https://api.os.uk/downloads/v1/products/CodePointOpen/downloads?area=GB&format=CSV&redirect"

        response = requests.get(url, timeout=(5, 30))

        logger.info(f"Download request status code: {response.status_code}")

        temp_dir = tempfile.mkdtemp()
        zip_path = os.path.join(temp_dir, "postcodes.zip")

        logger.info(f"Saving zip file to: {zip_path}")

        with open(zip_path, "wb") as f:
            f.write(response.content)

        with zipfile.ZipFile(zip_path, "r") as zip_ref:
            zip_ref.extractall(temp_dir)

        return {"temp_dir": temp_dir}

    @task
    def create_postgres_table():
        """Create the Postgres table if it doesn't exist"""
        pg_hook = PostgresHook(postgres_conn_id="postgres_default")

        create_table_sql = """
        CREATE TABLE IF NOT EXISTS postcodes (
            postcode VARCHAR(8),
            positional_quality_indicator INTEGER,
            eastings INTEGER,
            northings INTEGER,
            country_code VARCHAR(9),
            nhs_regional_ha_code VARCHAR(9),
            nhs_ha_code VARCHAR(9),
            admin_county_code VARCHAR(9),
            admin_district_code VARCHAR(9),
            admin_ward_code VARCHAR(9)
        );

        TRUNCATE TABLE postcodes;
        """
        pg_hook.run(create_table_sql)
        logger.info("Postgres table created successfully")

    @task
    def load_to_postgres(download_info: Dict[str, str]):
        """Load CSV files directly to Postgres"""
        temp_dir = download_info["temp_dir"]
        logger.info(f"Starting to load data to Postgres from: {temp_dir}")

        pg_hook = PostgresHook(postgres_conn_id="postgres_default")

        processed_count = 0
        data_dir = os.path.join(temp_dir, "Data", "CSV")
        logger.info(f"Starting to load files from: {data_dir}")

        copy_sql = """
                COPY postcodes FROM STDIN WITH (
                    FORMAT CSV,
                    HEADER true
                )
            """

        for filename in os.listdir(data_dir):
            if filename.endswith(".csv"):
                file_path = os.path.join(data_dir, filename)

                pg_hook.copy_expert(copy_sql, file_path)

                # Get number of rows inserted
                processed_count += (
                    sum(1 for _ in open(file_path)) - 1
                )  # subtract 1 for header

        # Clean up
        # os.remove(temp_dir)
        shutil.rmtree(temp_dir)
        return {"processed_records": processed_count}

    # Define task dependencies
    download_info = download_postcode_data()
    _ = create_postgres_table() >> load_to_postgres(download_info)
    # create_postgres_table()
    # load_info = load_to_postgres(download_info)


# Create DAG instance
dag = ons_postcode_pipeline()
