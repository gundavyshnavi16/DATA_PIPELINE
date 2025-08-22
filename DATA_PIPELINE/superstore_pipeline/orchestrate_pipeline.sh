#!/bin/bash
# Stop the script immediately if any command fails
set -e

echo "Starting Docker services..."
# Spin up all containers defined in docker-compose.yml
# --remove-orphans ensures any old/unused containers are cleaned up
docker compose up -d --remove-orphans

echo "Running ETL script..."
# Run our Python ETL script inside the 'etl' container
docker compose exec etl python etl/extract_load.py

# --- DBT AND METADATA LOGIC ---

echo " Running dbt models..."
# Run dbt models inside the 'dbt' container
# Save the output into dbt/logs/dbt_output.log for later reference
# The '|| true' makes sure script continues even if dbt run fails
docker compose exec dbt dbt run > dbt/logs/dbt_output.log 2>&1 || true

echo "Running dbt tests..."
# Run dbt tests and append the results to the same log file
# Again, '|| true' ensures the script doesn’t stop if tests fail
docker compose exec dbt dbt test >> dbt/logs/dbt_output.log 2>&1 || true

echo "dbt commands completed!"

echo " Updating pipeline metadata..."

# Grab the latest run_id from our pipeline_metadata table
# (this is the unique identifier for the current pipeline run)
LATEST_RUN_ID=$(docker compose exec -T postgres psql -U superuser -d superstore -t -c "SELECT MAX(run_id) FROM pipeline_metadata;" | xargs)

# Count how many dbt tests passed and failed by looking inside the log file
# grep searches for the words PASS/FAIL, wc -l counts them
# '|| true' prevents errors if grep finds nothing
PASS_COUNT=$(grep -o "PASS" dbt/logs/dbt_output.log | wc -l || true)
FAIL_COUNT=$(grep -o "FAIL" dbt/logs/dbt_output.log | wc -l || true)

# Default pipeline run status to "success" unless we detect failures
STATUS="success"
if [ "$FAIL_COUNT" -gt 0 ]; then STATUS="fail"; fi

# Update the metadata table so we can track run results in the database
docker compose exec -T postgres psql -U superuser -d superstore -c "
  UPDATE pipeline_metadata
  SET model_run_status = '$STATUS',
      tests_passed = $PASS_COUNT,
      tests_failed = $FAIL_COUNT
  WHERE run_id = $LATEST_RUN_ID;
"

echo " Pipeline metadata updated!"
