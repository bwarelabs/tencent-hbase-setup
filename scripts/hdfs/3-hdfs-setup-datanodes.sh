#!/usr/bin/env bash

HADOOP_VERSION={{hadoop_version}}
HADOOP_HOME_DIR={{hadoop_home}}
NAMENODES_IPS={{namenodes_ips}}
HADOOP_DATA_DIR=$HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/data
HADOOP_USER="hadoop"

configure_hadoop_site() {
    echo "configure_hadoop_site: configure hadoop site for datanode"
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
    
    echo "</configuration>" >> $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/hdfs-site.xml
}

configure_datanode_data_dir() {
    echo "configure_datanode_data_dir: setting up datanode directories"
    sudo mkdir -p $HADOOP_DATA_DIR
    sudo chown -R $HADOOP_USER:$HADOOP_USER $HADOOP_DATA_DIR
}

start_datanode_service() {
  echo "start_datanode_service: checking if datanode service is already running..."
  if ! sudo -u $HADOOP_USER bash -c "source $HADOOP_HOME_DIR/.bashrc && jps | grep -q DataNode"; then
      echo "start_datanode_service: starting datanode service..."
      sudo -u $HADOOP_USER bash -c "source $HADOOP_HOME_DIR/.bashrc && hdfs --daemon start datanode"
      if [ $? -eq 0 ]; then
          echo "start_datanode_service: datanode service started successfully."
      else
          echo "start_datanode_service: failed to start datanode service. Check the logs for details."
      fi
  else
      echo "start_datanode_service: datanode service is already running."
  fi
}

# ------------------------------
# main
# ------------------------------

configure_hadoop_site
configure_datanode_data_dir
start_datanode_service
