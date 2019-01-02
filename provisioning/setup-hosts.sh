#!/bin/bash

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set -o xtrace

MASTER_IP=$1
MASTER_HOSTNAME=$2
NODE1_IP=$3
NODE1_HOSTNAME=$4
NODE2_IP=$5
NODE2_HOSTNAME=$6

function createHosts {
    echo "generating hosts"
    cat << HOSTEOF | sudo tee /etc/hosts
$MASTER_IP $MASTER_HOSTNAME
$NODE1_IP $NODE1_HOSTNAME
$NODE2_IP $NODE2_HOSTNAME
HOSTEOF
}

function closeFirewall {
    sudo systemctl stop firewalld.service
}

function configSSHKey {
    echo "config ssh key"
    cp -f /vagrant/.ssh/id_rsa* ~/.ssh/
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    cat << CONFIG >> ~/.ssh/config
Host *
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
CONFIG

    chmod 600 ~/.ssh/id_rsa
    chmod 600 ~/.ssh/authorized_keys
}

createHosts
closeFirewall
configSSHKey


# Restore xtrace
$XTRACE
