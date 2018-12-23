#!/bin/bash

function installLocalJava {
    echo "installing oracle jdk"
    FILE=/vagrant/resources/$JAVA_ARCHIVE
    tar -xzf $FILE -C /usr/local
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
        ln -s /usr/local/jdk1.8.0_191 /usr/local/java
    else
        ln -s /usr/lib/jvm/jre /usr/local/java
    fi

    echo "creating java environment variables"
    echo export JAVA_HOME=/usr/local/java >> /etc/profile.d/java.sh
    echo export PATH=\${JAVA_HOME}/bin:\${PATH} >> /etc/profile.d/java.sh
}
