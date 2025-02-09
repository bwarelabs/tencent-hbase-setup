#!/usr/bin/env bash

HBASE_VERSION={{hbase_version}}
HBASE_HOME={{hbase_home}}
ZOOKEEPER_IPS={{zookeeper_ips}}
NAMENODES_IPS={{namenodes_ips}}
HBASE_USER="hbase"

HADOOP_VERSION={{hadoop_version}}
HADOOP_HOME_DIR={{hadoop_home}}
HADOOP_USER="hadoop"

HBASE_MASTERS_IPS={{hbase_masters_ips}}

wait_for_hbase_ready() {
    echo "Waiting for HBase Master and RegionServers to be online..."
    while ! echo "status 'detailed'" | hbase shell | grep -q "servers"; do
        sleep 5
    done
    echo "HBase Master and RegionServers are active."
}

create_hbase_tables() {
    wait_for_hbase_ready  # Ensure everything is up before proceeding

    echo "Creating tables if not already present..."
    TABLES=("blocks" "entries" "tx" "tx-by-addr" "tx_full")

    for TABLE in "${TABLES[@]}"; do
        if ! echo "exists '$TABLE'" | hbase shell | grep -q "Table $TABLE does exist"; then
            echo "create '$TABLE', 'x'" | hbase shell
            echo "Table $TABLE created successfully."
        else
            echo "Table $TABLE already exists, skipping creation."
        fi
    done

    echo "All tables are set up successfully."
}

# Run table creation process
create_hbase_tables
