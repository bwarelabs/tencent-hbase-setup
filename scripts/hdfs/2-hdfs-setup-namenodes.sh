#!/usr/bin/env bash

HADOOP_VERSION={{hadoop_version}}
HADOOP_HOME_DIR={{hadoop_home}}
ZOOKEEPER_IPS_EDITS={{zookeeper_ips_edits}}
ZOOKEEPER_IPS={{zookeeper_ips}}
NAMENODES_IPS={{namenodes_ips}}
HADOOP_DATA_DIR=$HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/data
HADOOP_USER="hadoop"

configure_hadoop_site() {
    echo "configure_hadoop_site: configure hadoop site"
      IFS=',' read -r -a NAMENODES_IPS_ARRAY <<< "$NAMENODES_IPS"
    echo "configure_hadoop_site: ${NAMENODES_IPS_ARRAY[@]}"

    cat <<EOT > $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/hdfs-site.xml
<configuration>
  <!-- Define the name service -->
  <property>
    <name>dfs.nameservices</name>
    <value>solana</value>
  </property>

  <!-- Define the Namenodes for the name service -->
  <property>
    <name>dfs.ha.namenodes.solana</name>
    <value>$(printf "nn%d," $(seq 1 ${#NAMENODES_IPS_ARRAY[@]}) | sed 's/,$//')</value>
  </property>

  <!-- Define the NameNode directories for storing metadata -->
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file://$HADOOP_DATA_DIR</value>
  </property>

EOT
    for i in "${!NAMENODES_IPS_ARRAY[@]}"; do
        nn_index="nn$((i+1))"
        nn_ip="${NAMENODES_IPS_ARRAY[i]}"
        cat <<EOT >> $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/hdfs-site.xml
  <!-- Define the RPC addresses for the Namenodes -->
  <property>
    <name>dfs.namenode.rpc-address.solana.${nn_index}</name>
    <value>${nn_ip}:8020</value>
  </property>

  <!-- Define the HTTP addresses for the Namenodes -->
  <property>
    <name>dfs.namenode.http-address.solana.${nn_index}</name>
    <value>${nn_ip}:9870</value>
  </property>
EOT
    done

    cat <<EOT >> $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/hdfs-site.xml
  <!-- Client failover settings -->
  <property>
    <name>dfs.client.failover.proxy.provider.solana</name>
    <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
  </property>

  <!-- JournalNodes for shared edits -->
  <property>
    <name>dfs.namenode.shared.edits.dir</name>
    <value>qjournal://$ZOOKEEPER_IPS_EDITS/solana</value>
  </property>

  <!-- ZooKeeper settings -->
  <property>
    <name>ha.zookeeper.quorum</name>
    <value>$ZOOKEEPER_IPS</value>
  </property>

  <!-- Automatic failover settings -->
  <property>
    <name>dfs.ha.automatic-failover.enabled</name>
    <value>true</value>
  </property>

  <property>
    <name>dfs.ha.zkfc</name>
    <value>true</value>
  </property>

  <property>
    <name>dfs.ha.zkfc.port</name>
    <value>8019</value> <!-- Default port for ZKFC -->
  </property>

  <property>
    <name>dfs.ha.fencing.methods</name>
    <value>shell($HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/scripts/fencing.sh)</value>
  </property>
</configuration>
EOT
}

configure_namenode_data_dir() {
  echo "configure_namenode_data_dir: creating namenode data directory"
  mkdir -p $HADOOP_DATA_DIR
  sudo chown -R $HADOOP_USER:$HADOOP_USER $HADOOP_DATA_DIR

  if [ -z "$(ls -A $HADOOP_DATA_DIR)" ]; then
    echo "configure_namenode_data_dir: formatting the namenode data directory"
    sudo -u hadoop $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/bin/hdfs namenode -format -force
  fi
}

create_fencing_script() {
    echo "create_fencing_script: create fencing script"
    mkdir -p $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/scripts
    sudo chown -R $HADOOP_USER:$HADOOP_USER $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/scripts
    sudo touch $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/scripts/fencing.sh
    sudo chmod +x $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/scripts/fencing.sh

    cat <<EOT > $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/scripts/fencing.sh
sudo -u hadoop $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/bin/hdfs --daemon stop namenode
if [ $? -eq 0 ]; then
    echo "create_fencing_script: namenode service stopped successfully."
else
    echo "create_fencing_script: failed to stop namenode service."
    exit 1
fi

EOT
}

configure_namenode_zkfc() {
  echo "configure_namenode_zkfc: "
  FLAG_FILE="/var/lib/hadoop-hdfs/zkfc_format_done"

  if [ ! -f "$FLAG_FILE" ]; then
    echo "configure_namenode_zkfc: formatting zookeeper for hdfs..."
    sudo -u hadoop $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/bin/hdfs zkfc -formatZK
    
    if [ $? -eq 0 ]; then
      echo "configure_namenode_zkfc: zooKeeper formatting completed successfully."
      touch "$FLAG_FILE"
    else
      echo "configure_namenode_zkfc: zooKeeper formatting failed."
      exit 1
    fi
  else
    echo "configure_namenode_zkfc: zooKeeper has already been formatted."
  fi
}

start_zkfs_service() {
  echo "start_zkfs_service: checking if zkfc service is already running..."
  if ! sudo -u $HADOOP_USER bash -c "source $HADOOP_HOME_DIR/.bashrc && jps | grep -q DFSZKFailoverController"; then
      echo "start_zkfs_service: starting zkfc service..."
      sudo -u $HADOOP_USER bash -c "source $HADOOP_HOME_DIR/.bashrc && hdfs --daemon start zkfc"
      if [ $? -eq 0 ]; then
          echo "start_zkfs_service: zkfc service started successfully."
      else
          echo "start_zkfs_service: failed to start zkfc service. Check the logs for details."
      fi
  else
      echo "start_zkfs_service: zkfc service is already running."
  fi
}

start_namenode_service() {
  echo "start_namenode_service: checking if namenode service is already running..."
  if ! sudo -u $HADOOP_USER bash -c "source $HADOOP_HOME_DIR/.bashrc && jps | grep -q NameNode"; then
      echo "start_namenode_service: starting namenode service..."
      sudo -u $HADOOP_USER bash -c "source $HADOOP_HOME_DIR/.bashrc && hdfs --daemon start namenode"
      if [ $? -eq 0 ]; then
          echo "start_namenode_service: namenode service started successfully."
      else
          echo "start_namenode_service: failed to start namenode service. Check the logs for details."
      fi
  else
      echo "start_namenode_service: namenode service is already running."
  fi
}

# ------------------------------
# main
# ------------------------------

configure_hadoop_site
create_fencing_script
configure_namenode_data_dir
configure_namenode_zkfc
start_zkfs_service
start_namenode_service
