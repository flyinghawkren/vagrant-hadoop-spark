#!/bin/bash

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set -o xtrace

OVERLAY_IP=$1
MASTER1=$2
MASTER2=$3
PUBLIC_SUBNET_MASK=$4
MINION_NAME=$5
GW_IP=$6
K8S_VERSION=$7
UNDERLAY_IP=$8

cat > setup_minion_args.sh <<EOL
MASTER1=$MASTER1
MASTER2=$MASTER2
OVERLAY_IP=$OVERLAY_IP
PUBLIC_SUBNET_MASK=$PUBLIC_SUBNET_MASK
MINION_NAME=$MINION_NAME
GW_IP=$GW_IP
EOL

# FIXME(mestery): Remove once Vagrant boxes allow apt-get to work again
sudo rm -rf /var/lib/apt/lists/*

# Add external repos to install docker, k8s and OVS from packages.
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" |  sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo su -c "echo \"deb https://apt.dockerproject.org/repo ubuntu-xenial main\" >> /etc/apt/sources.list.d/docker.list"
sudo apt-get update

## First, install docker
sudo apt-get purge lxc-docker
sudo apt-get install -y docker-engine
sudo service docker start


## Install kubernetes
sudo swapoff -a
sudo apt-get install -y kubelet=${K8S_VERSION} kubeadm=${K8S_VERSION}
sudo sed -i "s/KUBELET_EXTRA_ARGS=*/KUBELET_EXTRA_ARGS=--node-ip=${OVERLAY_IP}/g" /etc/default/kubelet
sudo service kubelet restart

# Start kubelet join the cluster
cat /vagrant/kubeadm.log > kubeadm_join.sh
sudo sh kubeadm_join.sh

sleep 10

IFACE_UNDERLAY=$(ip addr | grep ${UNDERLAY_IP} | awk '{print $7}')
sudo ip link set ${IFACE_UNDERLAY} promisc on

# Restore xtrace
$XTRACE
