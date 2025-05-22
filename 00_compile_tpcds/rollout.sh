#!/bin/bash
set -e

PWD=$(get_pwd ${BASH_SOURCE[0]})
step="compile_tpcds"

log_time "Step ${step} started"
printf "\n"

init_log ${step}
start_log
schema_name="${SCHEMA_NAME}"
export schema_name
table_name="compile"
export table_name

compile_flag="true"

function make_tpc() {
  #compile the tools
  cd ${PWD}/tools
  rm -f ./*.o
  ADDITIONAL_CFLAGS_OPTION="-g -Wno-unused-function -Wno-unused-but-set-variable -Wno-format -fcommon" make
  cd ..
}


function copy_tpc() {
  cp ${PWD}/tools/dsqgen ../*_sql/
  cp ${PWD}/tools/dsqgen ../*_multi_user/
  cp ${PWD}/tools/dsdgen ../*_gen_data/
  cp ${PWD}/tools/tpcds.idx ../*_sql/
  cp ${PWD}/tools/tpcds.idx ../*_multi_user/
  cp ${PWD}/tools/tpcds.idx ../*_gen_data/

  #copy the compiled dsdgen program to the segment nodes when running in LOCAL mode
  if [ "${RUN_MODEL}" == "local" ]; then
    echo "copy tpcds binaries to segment hosts"
    echo "RUN_MODEL is LOCAL, proceeding with copying binaries"
    for i in $(cat ${TPC_DS_DIR}/segment_hosts.txt); do
      scp tools/dsdgen tools/tpcds.idx ${i}: &
    done
    wait
  else
    echo "RUN_MODEL is not LOCAL, skipping copying binaries"
  fi
}


function copy_queries() {
  rm -rf ${TPC_DS_DIR}/*_sql/query_templates
  rm -rf ${TPC_DS_DIR}/*_multi_user/query_templates
  cp -R query_templates ${TPC_DS_DIR}/*_sql/
  cp -R query_templates ${TPC_DS_DIR}/*_multi_user/
}

function check_binary() {
  set +e
  
  cd ${PWD}/tools/
  cp -f dsqgen.${CHIP_TYPE} dsqgen
  cp -f dsdgen.${CHIP_TYPE} dsdgen
  chmod +x dsqgen
  chmod +x dsdgen

  ./dsqgen -help
  if [ $? == 0 ]; then 
    ./dsdgen -help
    if [ $? == 0 ]; then
      compile_flag="false" 
    fi
  fi
  cd ..
  set -e
}

function check_chip_type() {
  # Get system architecture information
  ARCH=$(uname -m)

  # Determine the architecture type and assign to variable
  if [[ $ARCH == *"x86"* || $ARCH == *"i386"* || $ARCH == *"i686"* ]]; then
    export CHIP_TYPE="x86"
  elif [[ $ARCH == *"arm"* || $ARCH == *"aarch64"* ]]; then
    export CHIP_TYPE="arm"
  else
    export CHIP_TYPE="unknown"
  fi

  # Print the result for verification
  echo "Chip type: $CHIP_TYPE"
}

check_chip_type
check_binary

if [ "${compile_flag}" == "true" ]; then
  make_tpc
else
  echo "Binary works, no compiling needed."
fi
create_hosts_file
copy_tpc
copy_queries
print_log

log_time "Step ${step} finished"
printf "\n"