
# Record Linkage in Clickhouse
Small personal project created to test ClickHouse's ability to perform record linkage on tables with populated by hundereds of millions of rows

## Overview
Given two  datasets (each containing **100 million individuals**), the goal is to link records that likely refer to the same person, based on approximate name matching using a **Soundex-based grouping strategy**.
ClickHouse is used as data engine.

## Structure
```bash
project
├── data 								# here will be generated the files
│   ├── dataset_a_fake.csv
│   └── dataset_b_fake.csv
└── script
    ├── py
    │   └── generateRandomData.py 		# Generate fake datasets using Faker + multiprocessing
    └── sh_sql
        ├── batchJoin.sh 				# the record linkage script
        ├── initialSetup.sh 			# setup of the database
        └── loadDataset.sh 				# loads data into the raw tables, then proceeds to calculate their index in a final table
```
		
## How it works

1. **Fake Data Generation**
   - Two datasets (`dataset_a'` `dataset_b`) of N rows each
   - Data includes: `id` (autoincrement), `first name`, `last name`
   - datasets are loaded in `dataset_a_raw` and `dataset_b_raw` tables

2. **Grouping using Soundex**
   - Each record is assigned a group key: `soundex(first_name) + soundex(last_name)`.This is done directly in clickhouse
   - A table 'distinct_soundex' is generated, listing all group keys

3. **Batch Join**
   - Global joins use too much memory, so soundex groups are joined in batches 
   - Results are inserted into a `matches` table

## How to Run

### 1. Generate data 
by passing the number of record per dataset and the directory in which the files will be generated:
```bash
python3 script/py/generateRandomData.py <NUM_ROWS> <DATASETS_PATH>
```
### 2. Setup database 
by passing parameters for clickhouse connection
```bash
script/sh_sql/initialSetup.sh <HOST> <PORT> <USER> <PASSWORD>
```
### 3. Load data
by passing parameters for clickhouse connection + the directory in which the datasets have been generated
```bash
script/sh_sql/loadDataset.sh <HOST> <PORT> <USER> <PASSWORD> <DATASETS_PATH>
```
### 4 Record Linkage
by passing parameters for clickhouse connection + batch size (the number of distinct group keys per batch)
```bash
script/sh_sql/batchJoin.sh <HOST> <PORT> <USER> <PASSWORD> <BATCH_SIZE>
```
