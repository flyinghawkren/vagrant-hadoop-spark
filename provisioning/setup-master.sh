#!/bin/bash

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set -o xtrace

source "/vagrant/provisioning/setup-java.sh"
source "/vagrant/provisioning/setup-hadoop.sh"

setupJava
setupHadoop master

# Restore xtrace
$XTRACE
