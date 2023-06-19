#!/bin/bash

# Assign command-line arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Check # of args
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Collect host hardware specifications using bash commands
hostname=$(hostname -f| xargs)
lscpu_out=$(lscpu)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "Model\s" | awk '{$1=""; $2=""; print $0}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | egrep "MHz" | awk '{print $3}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "L2" | awk '{print $3}' | sed 's/K//'| xargs)
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
total_mem=$(free -m | awk '/^Mem:/{print $2}')

# Construct the INSERT statement using specification variables
insert_stmt="INSERT INTO host_info ( id, hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem)VALUES (DEFAULT,'$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

#set up env var for pql cmd
export PGPASSWORD=$psql_password

# Execute the INSERT statement through the psql CLI tool
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit $?
