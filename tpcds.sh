#!/bin/bash
set -e

VARS_FILE="tpcds_variables.sh"
FUNCTIONS_FILE="functions.sh"

# shellcheck source=tpcds_variables.sh
source ./${VARS_FILE}
# shellcheck source=functions.sh
source ./${FUNCTIONS_FILE}

if [ "${RUN_MODEL}" != "cloud" ]; then
  source_bashrc
fi

TPC_DS_DIR=$(get_pwd ${BASH_SOURCE[0]})
export TPC_DS_DIR

log_time "TPC-DS test started"
printf "\n"

# Check that pertinent variables are set in the variable file.
check_variables
# Make sure this is being run as gpadmin
check_admin_user
# Output admin user and multi-user count to standard out
print_header

# run the benchmark
./rollout.sh
