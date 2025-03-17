# Environment options
export ADMIN_USER="gpadmin"
export BENCH_ROLE="dsbench"
export SCHEMA_NAME="tpcds"
export GREENPLUM_PATH=$GPHOME/greenplum_path.sh
## Set chip type to arm or x86 to avoid compiling TPC-DS tools from source code.
export CHIP_TYPE="x86"
 
## Set to "local" to run the benchmark on the COORDINATOR host or "cloud" to run the benchmark on remote cluster
export RUN_MODEL="cloud"

## Default port used is configed via env setting of $PGPORT for user $ADMIN_USER
## Confige the host/port/user to connect to the cluster running the test, can left empty when running local mode with gpadmin.
export PSQL_OPTIONS="-h 2f445c57-c838-4038-a410-50ee36f9461d.cloud.hashdata.ai -p 5432"

## Follwoing variables only take effect when RUN_MODEL is set to "cloud".
### Default path to store the generated benchmark data, 
export CLIENT_GEN_PATH="/tmp/dsbenchmark"
### How many parallel processes to run on the client to generate data
export CLIENT_GEN_PARALLEL="2"

# Benchmark options
export GEN_DATA_SCALE="1"
export MULTI_USER_COUNT="2"

# Step options

## step 00_compile_tpcds
export RUN_COMPILE_TPCDS="true"

## step 01_gen_data
# To run another TPC-DS with a different BENCH_ROLE using existing tables and data
# the queries need to be regenerated with the new role
# change BENCH_ROLE and set RUN_GEN_DATA to true and GEN_NEW_DATA to false
# GEN_NEW_DATA only takes affect when RUN_GEN_DATA is true, and the default setting
# should true under normal circumstances
export RUN_GEN_DATA="true"
export GEN_NEW_DATA="true"

## step 02_init
export RUN_INIT="true"
## set this to true if binary location changed
export RESET_ENV_ON_SEGMENT='false'

## step 03_ddl
# To run another TPC-DS with a different BENCH_ROLE using existing tables and data
# change BENCH_ROLE and set RUN_DDL to true and DROP_EXISTING_TABLES to false
# DROP_EXISTING_TABLES only takes affect when RUN_DDL is true, and the default setting
# should true under normal circumstances
export RUN_DDL="true"
export DROP_EXISTING_TABLES="true"

## step 04_load
export RUN_LOAD="true"

## step 05_sql
export RUN_SQL="true"
export RUN_ANALYZE="true"
export RUN_QGEN="true"
## set wait time between each query execution
export QUERY_INTERVAL="0"
## Set to 1 if you want to stop when error occurs
export ON_ERROR_STOP="0"

## step 06_single_user_reports
export RUN_SINGLE_USER_REPORTS="true"

## step 07_multi_user
export RUN_MULTI_USER="false"
export RUN_MULTI_USER_QGEN="true"

## step 08_multi_user_reports
export RUN_MULTI_USER_REPORTS="false"

## step 09_score
export RUN_SCORE="false"

# Misc options
export SINGLE_USER_ITERATIONS="1"
export EXPLAIN_ANALYZE="false"
export RANDOM_DISTRIBUTION="true"
## Set to on/off to enable vectorization
export ENABLE_VECTORIZATION="off"
export STATEMENT_MEM="2GB"
export STATEMENT_MEM_MULTI_USER="1GB"
## Set gpfdist location where gpfdist will run p (primary) or m (mirror)
export GPFDIST_LOCATION="p"
export OSVERSION=$(uname)
export ADMIN_USER=$(whoami)
export ADMIN_HOME=$(eval echo ${HOME}/${ADMIN_USER})
export MASTER_HOST=$(hostname -s)
export LD_PRELOAD=/lib64/libz.so.1 ps

# Storage options
## Support TABLE_ACCESS_METHOD to ao_row / ao_column / heap in both GPDB 7 / CBDB
## Support TABLE_ACCESS_METHOD to ”USING PAX“ for PAX table format and remove blocksize option in TABLE_STORAGE_OPTIONS for CBDB 2.0 only.
## DO NOT set TABLE_ACCESS_METHOD for Cloud
# export TABLE_ACCESS_METHOD="USING PAX"
## Set different storage options for each access method
## SET TABLE_STORAGE_OPTIONS wiht different options in GP/CBDB/Cloud "appendoptimized=true compresstype=zstd, compresslevel=5, blocksize=1048576"
export TABLE_STORAGE_OPTIONS="WITH (compresstype=zstd, compresslevel=5)"