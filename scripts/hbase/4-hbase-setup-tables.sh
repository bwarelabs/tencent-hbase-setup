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

create_hbase_tables() {
    echo "Creating tables if not already present..."
    TABLES=("blocks" "entries" "tx" "tx-by-addr" "tx_full")

    for TABLE in "${TABLES[@]}"; do
        if ! echo "exists '$TABLE'" | sudo -u $HBASE_USER bash -c "source ~/.bashrc && hbase shell" | grep -q "Table $TABLE does exist"; then
            echo "create '$TABLE', 'x'" | sudo -u $HBASE_USER bash -c "source ~/.bashrc && hbase shell"
            echo "Table $TABLE created successfully."
        else
            echo "Table $TABLE already exists, skipping creation."
        fi
    done

    echo "All tables are set up successfully."
}

create_hbase_tables
