#!/usr/bin/env bash

HADOOP_HOME={{hadoop_home}}

configure_hadoop_namenodes() {
    source ~/.bashrc

    echo "configure_hadoop_namenodes: format hdfs namenodes filesystem"
    $HADOOP_HOME/bin/hdfs namenode -format

    echo "configure_hadoop_namenodes: start the hdfs daemon"
    $HADOOP_HOME/sbin/start-dfs.sh
}

# ------------------------------
# main
# ------------------------------

configure_hadoop_namenodes
