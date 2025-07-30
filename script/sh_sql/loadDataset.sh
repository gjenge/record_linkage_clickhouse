#!/bin/bash

HOST=$1
PORT=$2
USER=$3
PASSWORD=$4
pathDatasets=$5
DELIMITER=";"
CLIENT="clickhouse-client --host ${HOST} --port ${PORT} --user ${USER} --password ${PASSWORD}"

run_query() {
  local query="$1"
  ${CLIENT} --query="${query}"
}

import_csv() {
  local table="$1"
  local filepath="$2"
  ${CLIENT} --query="INSERT INTO ${table} FORMAT CSV" --format_csv_delimiter="${DELIMITER}" < "${filepath}"
}

# 1. Svuota le tabelle raw
run_query "TRUNCATE TABLE record_linkage.dataset_a_raw"
run_query "TRUNCATE TABLE record_linkage.dataset_b_raw"

# 2. Carica i dati raw da CSV
import_csv "record_linkage.dataset_a_raw" "${pathDatasets}/dataset_a_fake.csv"
import_csv "record_linkage.dataset_b_raw" "${pathDatasets}/dataset_b_fake.csv"

# 3. Crea o sovrascrive le tabelle trasformate dataset_a e dataset_b
create_dataset_table() {
  local table_raw="$1"
  local table_final="$2"
  run_query "
    CREATE OR REPLACE TABLE ${table_final}
    ENGINE = MergeTree()
    ORDER BY id
    AS
    SELECT 
      id, 
      firstName, 
      lastName, 
      concat(soundex(firstName), soundex(lastName)) AS soundexCode
    FROM ${table_raw}
    ORDER BY soundexCode
  "
}

create_dataset_table "record_linkage.dataset_a_raw" "record_linkage.dataset_a"
create_dataset_table "record_linkage.dataset_b_raw" "record_linkage.dataset_b"

# 4. Crea la tabella con i soundex distinti
run_query "
  CREATE OR REPLACE TABLE record_linkage.distinct_soundex 
  ENGINE = MergeTree 
  ORDER BY soundexCode 
  AS 
  SELECT DISTINCT soundexCode 
  FROM record_linkage.dataset_a
"
