#!/bin/bash
HOST=$1
PORT=$2
USER=$3
PASSWORD=$4
BATCH_SIZE=$5
CLIENT="clickhouse-client --host ${HOST} --port ${PORT} --user ${USER} --password ${PASSWORD}"
TOTAL_SOUNDS=$(${CLIENT} --query "SELECT count(*) FROM record_linkage.distinct_soundex")
MAX_BATCH=$((TOTAL_SOUNDS / BATCH_SIZE))

for ((i=0; i<=MAX_BATCH; i++)); do
    OFFSET=$((i * BATCH_SIZE))
    echo "Esecuzione batch $i (offset=$OFFSET)"
    ${CLIENT} --query "
        INSERT INTO record_linkage.matches
        SELECT
            a.id AS id_a,
            b.id AS id_b,
            jaroSimilarity(concat(a.firstName, a.lastName), concat(b.firstName, b.lastName))
        FROM record_linkage.dataset_a a
        INNER JOIN record_linkage.dataset_b b ON a.soundexCode = b.soundexCode
        WHERE a.soundexCode IN (
            SELECT soundexCode
            FROM record_linkage.distinct_soundex
            ORDER BY soundexCode
            LIMIT $BATCH_SIZE OFFSET $OFFSET
        );
    "
done
