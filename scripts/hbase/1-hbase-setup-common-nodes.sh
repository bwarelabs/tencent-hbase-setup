#!/usr/bin/env bash

HBASE_VERSION={{hbase_version}}
HBASE_HOME={{hbase_home}}
JAVA_HOME={{java_home}}
HBASE_USER="hbase"

MANAGEMENT_IPS={{management_ips}}
MANAGEMENT_INSTANCE_NAME={{management_instance_name}}
WORKER_IPS={{worker_ips}}
WORKERS_INSTANCE_NAME={{workers_instance_name}}

create_hbase_user() {
    echo "create_hbase_user: creating hbase user..."

    if id "$HBASE_USER" &>/dev/null; then
        echo "create_hbase_user: user $HBASE_USER already exists."
    else
        sudo useradd -r -m -d $HBASE_HOME -s /bin/bash $HBASE_USER
        echo "$HBASE_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$HBASE_USER
    fi
}

install_hbase_packages() {
    echo "install_hbase_packages: installing hbase packages on the node"
    if [[ -e "./hbase-$HBASE_VERSION-bin.tar.gz" ]]; then
      echo "install_hbase_packages: hbase version already downloaded on the machine"
    else 
      url="https://downloads.apache.org/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz"
      echo "install_hbase_packages: downloading hbase from $url"
      wget -q $url
      sudo tar -xzf hbase-$HBASE_VERSION-bin.tar.gz -C /usr/local
      sudo mv /usr/local/hbase-$HBASE_VERSION $HBASE_HOME
    fi
}

set_environment_variables() {
    echo "set_environment_variables: set hbase environment variables"
    if ! grep -q "export JAVA_HOME=$JAVA_HOME" $HBASE_HOME/.bashrc; then
      echo "set_environment_variables: setting java home path"
      echo "export JAVA_HOME=$JAVA_HOME" >> $HBASE_HOME/.bashrc
    fi

    if ! grep -q "export HBASE_HOME=$HBASE_HOME/hbase-$HBASE_VERSION" $HBASE_HOME/.bashrc; then
        echo "set_environment_variables: setting hbase exec path"
        echo "export HBASE_HOME=$HBASE_HOME/hbase-$HBASE_VERSION" >> $HBASE_HOME/.bashrc
    fi

    if ! grep -q "export PATH=\$PATH:\$HBASE_HOME/bin" $HBASE_HOME/.bashrc; then
        echo "set_environment_variables: setting global path"
        echo "export PATH=\$PATH:\$HBASE_HOME/bin" >> $HBASE_HOME/.bashrc
    fi

    source ~/.bashrc
}

set_hosts_file() {
    IFS=',' read -r -a MANAGEMENT_IP_ARRAY <<< "$MANAGEMENT_IPS"
    IFS=',' read -r -a WORKER_IP_ARRAY <<< "$WORKER_IPS"
    > /etc/hosts

    echo "set_hosts_file: setting hosts file machines entries for local lookup"

    for i in "${!MANAGEMENT_IP_ARRAY[@]}"; do
        echo "set_hosts_file: adding ${MANAGEMENT_IP_ARRAY[i]} ${MANAGEMENT_INSTANCE_NAME}-${i}"
        echo "${MANAGEMENT_IP_ARRAY[i]} ${MANAGEMENT_INSTANCE_NAME}-${i}" >> /etc/hosts
    done

    # Add worker nodes to /etc/hosts
    for i in "${!WORKER_IP_ARRAY[@]}"; do
        echo "set_hosts_file: adding ${WORKER_IP_ARRAY[i]} ${WORKERS_INSTANCE_NAME}-${i}"
        echo "${WORKER_IP_ARRAY[i]} ${WORKERS_INSTANCE_NAME}-${i}" >> /etc/hosts
    done
    
    echo "${MANAGEMENT_IP_ARRAY[0]} solana" >> /etc/hosts
}

create_hbase_user
install_hbase_packages
set_environment_variables
set_hosts_file