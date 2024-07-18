#!/usr/bin/env bash

HADOOP_VERSION={{hadoop_version}}
HADOOP_HOME={{hadoop_home}}
HADOOP_DATA_DIR={{hadoop_data_dir}}
HADOOP_USER="hadoop"
JAVA_HOME={{java_home}}
QJOURNAL_PORT=8485

install_machine_packages() {
    echo "install_machine_packages: installing packages on the node"
    sudo yum install -y java-1.8.0-openjdk-devel wget
}

create_hadoop_user() {
    echo "create_hadoop_user: creating hadoop user..."

    if id "$HADOOP_USER" &>/dev/null; then
        echo "create_hadoop_user: user $HADOOP_USER already exists."
    else
        sudo useradd -r -m -d $HADOOP_HOME -s /bin/bash $HADOOP_USER
        echo "$HADOOP_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$HADOOP_USER
    fi
}

install_hadoop_packages() {
    echo "install_hadoop_packages: installing hadoop packages on the node"
    if [[ -e "./hadoop-$HADOOP_VERSION.tar.gz" ]]; then
      echo "install_hadoop_packages: hadoop version already downloaded on the machine"
    else 
      url="https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"
      echo "install_hadoop_packages: downloading hadoop from $url"
      wget $url
      sudo tar -xzvf hadoop-$HADOOP_VERSION.tar.gz -C /usr/local
      sudo mv /usr/local/hadoop-$HADOOP_VERSION $HADOOP_HOME
    fi
}

set_environment_variables() {
    echo "set_environment_variables: set hadoop environment variables"
    if ! grep -q "export JAVA_HOME=$JAVA_HOME" ~/.bashrc; then
      echo "set_environment_variables: setting java home path"
      echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
    fi

    if ! grep -q "export HADOOP_HOME=$HADOOP_HOME" ~/.bashrc; then
      echo "set_environment_variables: setting hadoop home path"
      echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc
    fi

    if ! grep -q "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" ~/.bashrc; then
      echo "set_environment_variables: setting global path"
      echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bashrc
    fi

    source ~/.bashrc
}

configure_qjournal_nodes() {
    echo "configure_qjournal_nodes: configuring Hadoop QJournalNodes..."
    sudo mkdir -p $HADOOP_DATA_DIR
    sudo chown -R $HADOOP_USER:$HADOOP_USER $HADOOP_DATA_DIR

    # Example Hadoop configuration for QJournalNodes
    sudo mkdir -p $HADOOP_HOME/etc/hadoop
    cat <<EOT | sudo tee $HADOOP_HOME/etc/hadoop/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.namenode.shared.edits.dir</name>
    <value>qjournal://localhost:$QJOURNAL_PORT/solana</value>
  </property>
  <property>
    <name>dfs.namenode.edits.dir</name>
    <value>file://$HADOOP_DATA_DIR/edits</value>
  </property>
</configuration>
EOT

    sudo chown -R $HADOOP_USER:$HADOOP_USER $HADOOP_HOME/etc/hadoop
}

set_environment_variables() {
    echo "set_environment_variables: setting environment variables..."
    if ! grep -q "export HADOOP_HOME=$HADOOP_HOME" $HADOOP_HOME/.bashrc; then
        echo "set_environment_variables: setting Hadoop home path"
        echo "export HADOOP_HOME=$HADOOP_HOME" >> $HADOOP_HOME/.bashrc
    fi
    
    if ! grep -q "export PATH=\$PATH:\$HADOOP_HOME/hadoop-$HADOOP_VERSION-bin/bin" $HADOOP_HOME/.bashrc; then
        echo "set_environment_variables: setting global path"
        echo "export PATH=\$PATH:\$HADOOP_HOME/hadoop-$HADOOP_VERSION-bin/bin" >> $HADOOP_HOME/.bashrc
    fi
}

start_qjournal_nodes() {
    echo "start_qjournal_nodes: starting QJournalNode services..."
    sudo -u $HADOOP_USER bash -c "source $HADOOP_HOME/.bashrc && hdfs --daemon start journalnode"
}

# ------------------------------
# main
# ------------------------------

install_machine_packages
create_hadoop_user
install_hadoop_packages
configure_qjournal_nodes
set_environment_variables
start_qjournal_nodes
