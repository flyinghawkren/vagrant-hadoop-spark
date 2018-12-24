#!/bin/bash

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set -o xtrace

source "/vagrant/provisioning/common.sh"
source "/vagrant/provisioning/setup-java.sh"
source "/vagrant/provisioning/setup-hadoop.sh"

setupJava
setupHadoop

# Restore xtrace
$XTRACE
