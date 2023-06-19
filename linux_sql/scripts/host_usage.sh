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
hostname=$(hostname -f | xargs)
timestamp=$(date "+%Y-%m-%d %H:%M:%S"| xargs)
memory_free=$(vmstat --unit M | tail -1 | awk '{print $4}'| xargs)
cpu_idle=$(vmstat | tail -1 | awk '{print $15}'| xargs)
cpu_kernel=$(vmstat | tail -1 | awk '{print $14}'| xargs)
disk_io=$(vmstat --unit M -d | tail -1 | awk '{print $10}'| xargs)
disk_available=$(df -BM / | tail -1 | awk '{print $4}'| sed 's/M//'| xargs)

#Subquery to find matching id in host_info table
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

# Construct the INSERT statement using specification variables
insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)VALUES ('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

#set up env var for pql cmd
export PGPASSWORD=$psql_password

# Execute the INSERT statement through the psql CLI tool
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit $?
