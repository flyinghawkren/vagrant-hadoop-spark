#!/bin/bash

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set -o xtrace

source "/vagrant/provisioning/setup-java.sh"
source "/vagrant/provisioning/setup-hadoop.sh"
source "/vagrant/provisioning/setup-spark.sh"

setupJava
setupHadoop node
setupSpark node

# Restore xtrace
$XTRACE
