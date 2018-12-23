#!/bin/bash

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set -o xtrace

MASTER_IP=$1

source "/vagrant/provisioning/common.sh"
source "/vagrant/provisioning/setup-java.sh"
source "/vagrant/provisioning/setup-hadoop.sh"

setupJava
setupHadoop $MASTER_IP

# Restore xtrace
$XTRACE
