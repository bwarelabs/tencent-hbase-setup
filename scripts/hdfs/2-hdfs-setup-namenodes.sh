#!/usr/bin/env bash

HADOOP_HOME={{hadoop_home}}
ZOOKEEPER_IPS_EDITS={{zookeeper_ips_edits}}
ZOOKEEPER_IPS={{zookeeper_ips}}
NAMENODES_IPS={{namenodes_ips}}

configure_hadoop_site() {
    echo "configure_hadoop_site: configure hadoop site"
      IFS=',' read -r -a NAMENODES_IPS_ARRAY <<< "$NAMENODES_IPS"
    echo "configure_hadoop_site: ${NAMENODES_IPS_ARRAY[@]}"

    cat <<EOT > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
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

EOT
    for i in "${!NAMENODES_IPS_ARRAY[@]}"; do
        nn_index="nn$((i+1))"
        nn_ip="${NAMENODES_IPS_ARRAY[i]}"
        cat <<EOT >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
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

    cat <<EOT >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
  <!-- Client failover settings -->
  <property>
    <name>dfs.client.failover.proxy.provider.solana</name>
    <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
  </property>

  <!-- JournalNodes for shared edits -->
  <property>
    <name>dfs.namenode.shared.edits.dir</name>
    <value>qjournal://${ZOOKEEPER_IPS_EDITS}/solana</value>
  </property>

  <!-- ZooKeeper settings -->
  <property>
    <name>ha.zookeeper.quorum</name>
    <value>${ZOOKEEPER_IPS}</value>
  </property>
</configuration>
EOT
}

# ------------------------------
# main
# ------------------------------

configure_hadoop_site
