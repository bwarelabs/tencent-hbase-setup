#!/usr/bin/env bash

ZOOKEEPER_VERSION={{zookeeper_version}}
ZOOKEEPER_HOME={{zookeeper_home}}
ZOOKEEPER_DATA_DIR={{zookeeper_data_dir}}
ZOOKEEPER_USER="zookeeper"
ZOOKEEPER_IPS={{zookeeper_ips}}
ZOOKEEPER_ID=${HOSTNAME##*-}

install_machine_packages() {
    echo "install_machine_packages: installing packages on the node"
    sudo yum install -y java-1.8.0-openjdk-devel wget
}

create_zookeeper_user() {
    echo "create_zookeeper_user: creating zookeeper user..."

    if id "$ZOOKEEPER_USER" &>/dev/null; then
        echo "create_zookeeper_user: user $ZOOKEEPER_USER already exists."
    else
        sudo useradd -r -m -d $ZOOKEEPER_HOME -s /bin/bash $ZOOKEEPER_USER
        echo "$ZOOKEEPER_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$ZOOKEEPER_USER
    fi
}

download_zookeeper() {
    echo "download_zookeeper: downloading zooKeeper..."
    if [[ -e "./apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz" ]]; then
        echo "download_zookeeper: zookeeper version already downloaded on the machine"
    else
        url="https://downloads.apache.org/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz"
        echo "download_zookeeper: downloading zookeeper from $url"
        wget $url
        sudo tar -xzvf apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz -C /usr/local
        sudo mv /usr/local/apache-zookeeper-$ZOOKEEPER_VERSION-bin $ZOOKEEPER_HOME
        sudo chown -R $ZOOKEEPER_USER:$ZOOKEEPER_USER $ZOOKEEPER_HOME
    fi
}

configure_zookeeper() {
    echo "configure_zookeeper: configuring zooKeeper..."
    sudo mkdir -p $ZOOKEEPER_DATA_DIR
    sudo chown -R $ZOOKEEPER_USER:$ZOOKEEPER_USER $ZOOKEEPER_DATA_DIR

    server_id=$(($ZOOKEEPER_ID + 1))
    echo "configure_zookeeper: configuring zooKeeper with ID $server_id..."
    echo "$server_id" | sudo tee "$ZOOKEEPER_DATA_DIR/myid"

    sudo mkdir -p $ZOOKEEPER_HOME/apache-zookeeper-$ZOOKEEPER_VERSION-bin/conf
    sudo chown -R $ZOOKEEPER_USER:$ZOOKEEPER_USER $ZOOKEEPER_HOME/apache-zookeeper-$ZOOKEEPER_VERSION-bin/conf   

    cat <<EOT | sudo tee $ZOOKEEPER_HOME/apache-zookeeper-$ZOOKEEPER_VERSION-bin/conf/zoo.cfg
tickTime=2000
dataDir=$ZOOKEEPER_DATA_DIR
clientPort=2181
maxClientCnxns=60
initLimit=10
syncLimit=5
EOT

    IFS=',' read -r -a ZOOKEEPER_IPS_ARRAY <<< "$ZOOKEEPER_IPS"
    echo "configure_zookeeper: ${ZOOKEEPER_IPS_ARRAY[@]}"

    for i in "${!ZOOKEEPER_IPS_ARRAY[@]}"; do
        server_config="server.$((i+1))=${ZOOKEEPER_IPS_ARRAY[$i]}:2888:3888"
        echo "configure_zookeeper: adding server config: $server_config"
        echo "$server_config" | sudo tee -a "$ZOOKEEPER_HOME/apache-zookeeper-$ZOOKEEPER_VERSION-bin/conf/zoo.cfg"
    done

    sudo chown -R $ZOOKEEPER_USER:$ZOOKEEPER_USER $ZOOKEEPER_HOME/apache-zookeeper-$ZOOKEEPER_VERSION-bin/conf
}

set_environment_variables() {
    echo "set_environment_variables: setting environment variables..."
    if ! grep -q "export ZOOKEEPER_HOME=$ZOOKEEPER_HOME" $ZOOKEEPER_HOME/.bashrc; then
        echo "set_environment_variables: setting zookeeper home path"
        echo "export ZOOKEEPER_HOME=$ZOOKEEPER_HOME" >> $ZOOKEEPER_HOME/.bashrc
    fi
    
    if ! grep -q "export PATH=\$PATH:\$ZOOKEEPER_HOME/apache-zookeeper-$ZOOKEEPER_VERSION-bin/bin" $ZOOKEEPER_HOME/.bashrc; then
        echo "set_environment_variables: setting global path"
        echo "export PATH=\$PATH:\$ZOOKEEPER_HOME/apache-zookeeper-$ZOOKEEPER_VERSION-bin/bin" >> $ZOOKEEPER_HOME/.bashrc
    fi
        
    source ~/.bashrc
}

start_zookeeper_service() {
    echo "start_zookeeper_service: starting ZooKeeper service..."
    sudo -u $ZOOKEEPER_USER bash -c "source $ZOOKEEPER_HOME/.bashrc && zkServer.sh start"
}

# ------------------------------
# main
# ------------------------------

install_machine_packages
create_zookeeper_user
download_zookeeper
configure_zookeeper
set_environment_variables
start_zookeeper_service
