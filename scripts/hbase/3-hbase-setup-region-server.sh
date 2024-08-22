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

configure_hbase_site() {
    echo "configure_hbase_site: configure hbase site for region server"
    cat <<EOF > $HBASE_HOME/hbase-$HBASE_VERSION/conf/hbase-site.xml
<configuration>
    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
    
    <!-- HBase Master -->
    <property>
        <name>hbase.master</name>
        <value>$HBASE_MASTERS_IPS</value>
    </property>
    
    <!-- HBase RegionServer -->
    <property>
        <name>hbase.regionserver.port</name>
        <value>16020</value>
    </property>

    <!-- HDFS Configuration -->
    <property>
        <name>hbase.root.logger</name>
        <value>INFO,console</value>
    </property>
    <property>
        <name>hbase.zookeeper.quorum</name>
        <value>$ZOOKEEPER_IPS</value>
    </property>
    <property>
        <name>hbase.zookeeper.property.clientPort</name>
        <value>2181</value>
    </property>
</configuration>
EOF
}

copy_configuration_files() {
    echo "copy_configuration_files: copying hdfs configuration file in the hbase home directory"
    cp $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/core-site.xml $HBASE_HOME/hbase-$HBASE_VERSION/conf/core-site.xml
    cp $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/hdfs-site.xml $HBASE_HOME/hbase-$HBASE_VERSION/conf/hdfs-site.xml    
}

set_hbase_owner() {
    echo "set_hbase_owner: setting up hbase user directory ownership"
    sudo chown -R $HBASE_USER:$HBASE_USER $HBASE_HOME
}

create_hbase_directories() {
    echo "create_hbase_directories: creating hbase hdfs directory"
    sudo -u $HADOOP_USER bash -c "source $HADOOP_HOME_DIR/.bashrc && hdfs dfs -mkdir /$HBASE_USER && hdfs dfs -chown $HBASE_USER:$HBASE_USER /$HBASE_USER"
}

start_hbase_service() {
  echo "start_hbase_service: checking if hbase service is already running..."
  if ! sudo -u $HBASE_USER bash -c "source $HBASE_HOME/.bashrc && ps aux | grep HRegionServer"; then
      echo "start_hbase_service: starting hbase service..."
      sudo -u $HBASE_USER bash -c "source $HBASE_HOME/.bashrc && hbase-daemon.sh start regionserver"
      if [ $? -eq 0 ]; then
          echo "start_hbase_service: hbase service started successfully."
      else
          echo "start_hbase_service: failed to start hbase service. Check the logs for details."
      fi
  else
      echo "start_hbase_service: hbase service is already running."
  fi
}

configure_hbase_site
copy_configuration_files
set_hbase_owner
create_hbase_directories
start_hbase_service
