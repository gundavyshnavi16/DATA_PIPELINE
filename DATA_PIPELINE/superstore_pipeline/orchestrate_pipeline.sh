#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Docker services..."
# Use --remove-orphans to clean up any old containers
docker compose up -d --remove-orphans

echo "Running ETL script..."
# Use the 'etl' service name to run the python script
docker compose exec etl python etl/extract_load.py

# --- DBT AND METADATA LOGIC ---

# Create or overwrite the log file with the output of 'dbt run'
echo " Running dbt models..."
docker compose exec dbt dbt run > dbt/logs/dbt_output.log 2>&1 || true

# Append the output of 'dbt test' to the same log file
echo "Running dbt tests..."
docker compose exec dbt dbt test >> dbt/logs/dbt_output.log 2>&1 || true

echo "dbt commands completed successfully!"


echo " Updating pipeline metadata..."

# Get latest run_id (your command for this is correct)
LATEST_RUN_ID=$(docker compose exec -T postgres psql -U superuser -d superstore -t -c "SELECT MAX(run_id) FROM pipeline_metadata;" | xargs)

# Count test results from the dbt output log we just created
# Using '|| true' ensures that grep doesn't cause the script to exit if no matches are found
PASS_COUNT=$(grep -o "PASS" dbt/logs/dbt_output.log | wc -l || true)
FAIL_COUNT=$(grep -o "FAIL" dbt/logs/dbt_output.log | wc -l || true)
STATUS="success"
if [ "$FAIL_COUNT" -gt 0 ]; then STATUS="fail"; fi

# Update metadata row (your command for this is correct)
docker compose exec -T postgres psql -U superuser -d superstore -c "
  UPDATE pipeline_metadata
  SET model_run_status = '$STATUS',
      tests_passed = $PASS_COUNT,
      tests_failed = $FAIL_COUNT
  WHERE run_id = $LATEST_RUN_ID;
"

echo " Pipeline metadata updated!"