#!/bin/bash
set -e

01_install_prereqs() {
    if test `egrep "ID=*.(ol|fedora)" /etc/os-release | wc -l` = "1"
    then
        yum install epel-release -y;
        yum install git jq wget -y;
    elif test `egrep "ID=*.(ubuntu|debian)" /etc/os-release | wc -l` = "1"
    then
        apt update;
        apt install git jq wget -y
    else
        echo "Not supported!"
        exit 1
    fi
}

02_download_node_exporter() {
    NODE_EXPORTER_VERSION=$( \
        curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest |\
        jq -r .tag_name | sed "s/^v//g" )
    NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
    wget ${NODE_EXPORTER_URL} -O /tmp/node_exporter.tar.gz
    tar zxvf /tmp/node_exporter.tar.gz
}

03_install_node_exporter() {
    useradd prometheus
    mkdir -p /opt/node_exporter
    cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /opt/node_exporter
    chown prometheus:prometheus /opt/node_exporter -R
    cp node_exporter.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable node_exporter
    systemctl start node_exporter
}

01_install_prereqs
02_download_node_exporter
03_install_node_exporter
