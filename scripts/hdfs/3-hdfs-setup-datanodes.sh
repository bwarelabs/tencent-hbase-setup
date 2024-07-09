#!/usr/bin/env bash

HADOOP_HOME={{hadoop_home}}

configure_hadoop_datanodes() {
    source ~/.bashrc

    echo "configure_hadoop_datanodes: start the hdfs daemon"
    $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
}

# ------------------------------
# main
# ------------------------------

configure_hadoop_datanodes
