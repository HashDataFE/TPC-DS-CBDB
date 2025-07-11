#!/bin/bash
set -e

PWD=$(get_pwd ${BASH_SOURCE[0]})

step="load"

log_time "Step ${step} started"
printf "\n"

init_log ${step}

filter="gpdb"

if [ "$DB_VERSION" = "synxdb" ]; then
    env_file="${GPHOME}/cluster_env.sh"
else
    env_file="${GPHOME}/greenplum_path.sh"
fi

function copy_script() {
  log_time "copy the start and stop scripts to the segment hosts in the cluster"
  for i in $(cat ${TPC_DS_DIR}/segment_hosts.txt); do
    log_time "scp start_gpfdist.sh stop_gpfdist.sh ${i}:"
    scp ${PWD}/start_gpfdist.sh ${PWD}/stop_gpfdist.sh ${i}: &
  done
  wait
}

function stop_gpfdist() {
  log_time "stop gpfdist on all ports"
  for i in $(cat ${TPC_DS_DIR}/segment_hosts.txt); do
    ssh -n $i "bash -c 'cd ~/; ./stop_gpfdist.sh'" &
  done
  wait
}

function start_gpfdist() {
  stop_gpfdist
  sleep 1
  get_gpfdist_port

  if [ "${DB_VERSION}" == "gpdb_4_3" ] || [ "${DB_VERSION}" == "gpdb_5" ]; then
    SQL_QUERY="select rank() over (partition by g.hostname order by p.fselocation), g.hostname, p.fselocation as path from gp_segment_configuration g join pg_filespace_entry p on g.dbid = p.fsedbid join pg_tablespace t on t.spcfsoid = p.fsefsoid where g.content >= 0 and g.role = '${GPFDIST_LOCATION}' and t.spcname = 'pg_default' order by g.hostname"
  else
    SQL_QUERY="select rank() over(partition by g.hostname order by g.datadir), g.hostname, g.datadir from gp_segment_configuration g where g.content >= 0 and g.role = '${GPFDIST_LOCATION}' order by g.hostname"
  fi

  flag=10
  for i in $(psql ${PSQL_OPTIONS} -v ON_ERROR_STOP=1 -q -A -t -c "${SQL_QUERY}"); do
    CHILD=$(echo ${i} | awk -F '|' '{print $1}')
    EXT_HOST=$(echo ${i} | awk -F '|' '{print $2}')
    GEN_DATA_PATH=$(echo ${i} | awk -F '|' '{print $3}'| sed 's#//#/#g')
    GEN_DATA_PATH="${GEN_DATA_PATH}/dsbenchmark"
    PORT=$((GPFDIST_PORT + flag))
    let flag=$flag+1
    log_time "ssh -n ${EXT_HOST} \"bash -c 'cd ~${ADMIN_USER}; ./start_gpfdist.sh $PORT ${GEN_DATA_PATH} ${env_file}'\""
    ssh -n ${EXT_HOST} "bash -c 'cd ~${ADMIN_USER}; ./start_gpfdist.sh $PORT ${GEN_DATA_PATH} ${env_file}'" &
  done
  wait
}

if [ "${RUN_MODEL}" == "remote" ]; then
  PORT=18888
  GEN_DATA_PATH=${CLIENT_GEN_PATH}
  sh ${PWD}/stop_gpfdist.sh
  sh ${PWD}/start_gpfdist.sh $PORT ${GEN_DATA_PATH} ${env_file}
elif [ "${RUN_MODEL}" == "local" ]; then
  copy_script
  start_gpfdist
fi
# need to wait for all the gpfdist processes to start
# sleep 10

# Create FIFO for concurrency control
mkfifo /tmp/$$.fifo
exec 5<> /tmp/$$.fifo
rm -f /tmp/$$.fifo

# Initialize tokens based on the value of LOAD_PARALLEL
for ((i=0; i<${LOAD_PARALLEL}; i++)); do
    echo >&5
done

# Use find to get just filenames, then process each file in numeric order
for i in $(find "${PWD}" -maxdepth 1 -type f -name "*.${filter}.*.sql" -printf "%f\n" | sort -n); do
    # Acquire a token to control concurrency
    read -u 5
    {
        start_log

        id=$(echo "${i}" | awk -F '.' '{print $1}')
        export id
        schema_name=${DB_SCHEMA_NAME}
        export schema_name
        table_name=$(echo "${i}" | awk -F '.' '{print $3}')
        export table_name

        if [ "${RUN_MODEL}" == "cloud" ]; then
            GEN_DATA_PATH=${CLIENT_GEN_PATH}
            tuples=0
            for file in "${GEN_DATA_PATH}/${table_name}"_[0-9]*_[0-9]*.dat; do
                if [ -e "$file" ]; then
                    #log_time "psql ${PSQL_OPTIONS} -v ON_ERROR_STOP=1 -c \"\COPY ${DB_SCHEMA_NAME}.${table_name} FROM '$file' DELIMITER '|' NULL AS '' ESCAPE E'\\\\\\\\' ENCODING 'LATIN1'\" | grep COPY | awk -F ' ' '{print \$2}'"
                    log_time "psql ${PSQL_OPTIONS} -v ON_ERROR_STOP=1 -c \"\COPY ${DB_SCHEMA_NAME}.${table_name} FROM '$file' WITH (FORMAT csv, DELIMITER '|', NULL '', ESCAPE E'\\\\\\\\', ENCODING 'LATIN1')\" | grep COPY | awk -F ' ' '{print \$2}'"
                    result=$(
                        psql ${PSQL_OPTIONS} -v ON_ERROR_STOP=1 -c "\COPY ${DB_SCHEMA_NAME}.${table_name} FROM '$file' WITH (FORMAT csv, DELIMITER '|', NULL '', ESCAPE E'\\\\', ENCODING 'LATIN1')" | grep COPY | awk -F ' ' '{print $2}'
                        exit ${PIPESTATUS[0]}
                    )
                    tuples=$((tuples + result))
                else
                    log_time "No matching files found for pattern: ${GEN_DATA_PATH}/${table_name}_[0-9]*_[0-9]*.dat"
                fi
            done
        else
            log_time "psql ${PSQL_OPTIONS} -v ON_ERROR_STOP=1 -f ${PWD}/${i} -v DB_SCHEMA_NAME=\"${DB_SCHEMA_NAME}\" | grep INSERT | awk -F ' ' '{print \$3}'"
            tuples=$(
                psql ${PSQL_OPTIONS} -v ON_ERROR_STOP=1 -f "${PWD}/${i}" \
                    -v DB_SCHEMA_NAME="${DB_SCHEMA_NAME}" | grep INSERT | awk -F ' ' '{print $3}'
                exit ${PIPESTATUS[0]}
            )
        fi

        print_log ${tuples}

        # Release the token
        echo >&5
    } &
done

# Wait for all background tasks to complete
wait

# Close the file descriptor
exec 5>&-

log_time "finished loading tables"

if [ "${RUN_MODEL}" == "remote" ]; then
  sh ${PWD}/stop_gpfdist.sh
elif [ "${RUN_MODEL}" == "local" ]; then
  stop_gpfdist
fi

log_time "Step ${step} finished"
printf "\n"