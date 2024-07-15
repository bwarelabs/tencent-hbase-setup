#!/usr/bin/env bash

HADOOP_HOME={{hadoop_home}}

configure_hadoop_namenodes() {
    source ~/.bashrc

    echo "configure_hadoop_namenodes: format hdfs namenodes filesystem"
    $HADOOP_HOME/bin/hdfs namenode -format

    echo "configure_hadoop_namenodes: start the hdfs daemon"
    $HADOOP_HOME/sbin/start-dfs.sh
}

configure_hadoop_site() {
    echo "configure_hadoop_site: configure hadoop site"
    cat <<EOT > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>3</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:///usr/local/hadoop/hdfs/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///usr/local/hadoop/hdfs/datanode</value>
  </property>
</configuration>
EOT
}

# ------------------------------
# main
# ------------------------------

configure_hadoop_namenodes
configure_hadoop_site