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
    echo "configure_hbase_site: configure hbase site for master"
    cat <<EOF > $HBASE_HOME/hbase-$HBASE_VERSION/conf/hbase-site.xml
<configuration>
    <property>
        <name>hbase.master.ipc.address</name>
        <value>0.0.0.0</value>
    </property>

    <property>
        <name>hbase.rootdir</name>
        <value>hdfs://solana/hbase</value>
    </property>
    <property>
        <name>dfs.client.failover.proxy.provider.solana</name>
        <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
    </property>

    <property>
        <name>hbase.master.ha.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>hbase.master.ha.zk.quorum</name>
        <value>$ZOOKEEPER_IPS</value>
    </property>
    <property>
        <name>hbase.master.ha.zk.port</name>
        <value>2181</value>
    </property>
    <property>
        <name>hbase.master.ha.zk.namespace</name>
        <value>hbase</value>
    </property>    

    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
    <property>
        <name>hbase.zookeeper.quorum</name>
        <value>$ZOOKEEPER_IPS</value>
    </property>
    <property>
        <name>hbase.zookeeper.property.clientPort</name>
        <value>2181</value>
    </property>
    <property>
        <name>hbase.master.wait.on.regionservers.mintostart</name>
        <value>1</value>
    </property>
    <property>
        <name>hbase.regionserver.lease.period</name>
        <value>600000</value>
    </property>

    <property>
        <name>hbase.regionserver.thrift.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>hbase.thrift.support.proxyuser</name>
        <value>true</value>
    </property>
    <property>
        <name>hbase.server.keyvalue.maxsize</name>
        <value>104857600</value>
    </property>
    <!-- default is 256MB 268435456, this is 1.5GB -->
    <property>
        <name>hbase.hregion.max.filesize</name>
        <value>1610612736</value>
    </property>
    <!-- default is 2 -->
    <property>
        <name>hbase.hregion.memstore.block.multiplier</name>
        <value>4</value>
    </property>
    <!-- default is 64MB 67108864 -->
    <property>
        <name>hbase.hregion.memstore.flush.size</name>
        <value>134217728</value>
    </property>
    <!-- default is 7, should be at least 2x compactionThreshold -->
    <property>
        <name>hbase.hstore.blockingStoreFiles</name>
        <value>200</value>
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
  if ! sudo -u $HBASE_USER bash -c "source $HBASE_HOME/.bashrc && ps aux | grep '[H]Master'"; then
      echo "start_hbase_service: starting hbase service..."
      sudo -u $HBASE_USER bash -c "source $HBASE_HOME/.bashrc && hbase-daemon.sh start master"
      if [ $? -eq 0 ]; then
          echo "start_hbase_service: hbase service started successfully."
      else
          echo "start_hbase_service: failed to start hbase service. Check the logs for details."
      fi
  else
      echo "start_hbase_service: hbase service is already running."
  fi
}

start_thrift_service() {
    echo "start_thrift_service: checking if thrift service is already running..."
    if ! sudo -u $HBASE_USER bash -c "source $HBASE_HOME/.bashrc && ps aux | grep '[T]hriftServer'"; then
        echo "start_thrift_service: starting thrift service..."
        sudo -u $HBASE_USER bash -c "source $HBASE_HOME/.bashrc && hbase-daemon.sh start thrift"
        if [ $? -eq 0 ]; then
            echo "start_thrift_service: thrift service started successfully."
        else
            echo "start_thrift_service: failed to start thrift service. Check the logs for details."
        fi
    else
        echo "start_thrift_service: thrift service is already running."
    fi
}

configure_hbase_site
copy_configuration_files
set_hbase_owner
create_hbase_directories
start_hbase_service
start_thrift_service
