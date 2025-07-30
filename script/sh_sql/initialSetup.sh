#!/bin/bash

# connection
HOST=$1
PORT=$2
USER=$3
PASSWORD=$4
CLIENT="clickhouse-client --host ${HOST} --port ${PORT} --user ${USER} --password ${PASSWORD}"

exec_sql() {
  local query="$1"
  ${CLIENT} --query="${query}"
}

exec_sql "CREATE DATABASE IF NOT EXISTS record_linkage"

exec_sql "
  CREATE TABLE IF NOT EXISTS record_linkage.dataset_a_raw (
    id UInt64,
    firstName String,
    lastName String
  ) ENGINE = MergeTree
  ORDER BY id
"

exec_sql "
  CREATE TABLE IF NOT EXISTS record_linkage.dataset_b_raw (
    id UInt64,
    firstName String,
    lastName String
  ) ENGINE = MergeTree
  ORDER BY id
"

exec_sql "
  CREATE OR REPLACE TABLE record_linkage.matches (
    id_a UInt64,
    id_b UInt64,
    similarity Float32
  ) ENGINE = MergeTree
  ORDER BY similarity
"
