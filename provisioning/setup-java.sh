#!/bin/bash

source "/vagrant/provisioning/common.sh"

function installLocalJava {
    echo "installing oracle jdk"
    FILE=/vagrant/resources/$JAVA_ARCHIVE
    sudo tar -xzf $FILE -C /usr/local
}

function installRemoteJava {
    echo "install open jdk"
    sudo apt-get update
    sudo apt-get install -y openjdk-8-jdk
}

function installJava {
    if resourceExists $JAVA_ARCHIVE; then
        installLocalJava
    else
        installRemoteJava
    fi
}

function setupJava {
    echo "setting up java"
    installJava

    if resourceExists $JAVA_ARCHIVE; then
        sudo ln -s /usr/local/jdk1.8.0_191 /usr/local/java
    else
        sudo ln -s /usr/lib/jvm/jre /usr/local/java
    fi

    echo "creating java environment variables"
    echo export JAVA_HOME=/usr/local/java | sudo tee /etc/profile.d/java.sh
    echo export PATH=\${JAVA_HOME}/bin:\${PATH} | sudo tee /etc/profile.d/java.sh
}
