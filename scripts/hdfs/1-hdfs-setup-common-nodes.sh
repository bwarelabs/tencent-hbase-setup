#!/usr/bin/env bash

HADOOP_VERSION={{hadoop_version}}
HADOOP_HOME_DIR={{hadoop_home}}
JAVA_HOME={{java_home}}
ZOOKEEPER_IPS={{zookeeper_ips}}
HADOOP_USER="hadoop"

install_machine_packages() {
    echo "install_machine_packages: installing packages on the node"
    sudo yum install -y java-1.8.0-openjdk-devel wget
}

create_hadoop_user() {
    echo "create_hadoop_user: creating hadoop user..."

    if id "$HADOOP_USER" &>/dev/null; then
        echo "create_hadoop_user: user $HADOOP_USER already exists."
    else
        sudo useradd -r -m -d $HADOOP_HOME_DIR -s /bin/bash $HADOOP_USER
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
      wget -q $url
      sudo tar -xzf hadoop-$HADOOP_VERSION.tar.gz -C /usr/local
      sudo mv /usr/local/hadoop-$HADOOP_VERSION $HADOOP_HOME_DIR
    fi
}

set_environment_variables() {
    echo "set_environment_variables: set hadoop environment variables"
    if ! grep -q "export JAVA_HOME=$JAVA_HOME" $HADOOP_HOME_DIR/.bashrc; then
      echo "set_environment_variables: setting java home path"
      echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME_DIR/.bashrc
    fi

    if ! grep -q "export HADOOP_HOME=$HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION" $HADOOP_HOME_DIR/.bashrc; then
        echo "set_environment_variables: setting hadoop exec path"
        echo "export HADOOP_HOME=$HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION" >> $HADOOP_HOME_DIR/.bashrc
    fi

    if ! grep -q "export PATH=\$PATH:\$HADOOP_HOME/bin" $HADOOP_HOME_DIR/.bashrc; then
        echo "set_environment_variables: setting global path"
        echo "export PATH=\$PATH:\$HADOOP_HOME/bin" >> $HADOOP_HOME_DIR/.bashrc
    fi

    source ~/.bashrc
}

configure_hadoop_env() {
    echo "configure_hadoop_env: configure hadoop environment"
    cat <<EOT > $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/hadoop-env.sh
export JAVA_HOME=$JAVA_HOME
EOT
}

configure_hadoop_core() {
    sudo mkdir -p $HADOOP_HOME_DIR
    sudo chown -R $HADOOP_USER:$HADOOP_USER $HADOOP_HOME_DIR

    echo "configure_hadoop_core: configure hadoop core"
    cat <<EOT > $HADOOP_HOME_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/core-site.xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://solana</value>
  </property>

  <property>
    <name>ha.zookeeper.quorum</name>
    <value>$ZOOKEEPER_IPS</value>
  </property>
</configuration>
EOT
}

# ------------------------------
# main
# ------------------------------

install_machine_packages
create_hadoop_user
install_hadoop_packages
set_environment_variables
configure_hadoop_env
configure_hadoop_core
