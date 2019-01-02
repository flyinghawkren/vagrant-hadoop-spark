#!/bin/bash

source "/vagrant/provisioning/common.sh"

function installLocalHadoop {
    echo "install hadoop from local file"
    FILE=/vagrant/resources/$HADOOP_ARCHIVE
    sudo tar -xzf $FILE -C /usr/local
}

function installRemoteHadoop {
    echo "install hadoop from remote file"
    sudo curl -sS -o /vagrant/resources/$HADOOP_ARCHIVE -O -L $HADOOP_MIRROR_DOWNLOAD
    sudo tar -xzf /vagrant/resources/$HADOOP_ARCHIVE -C /usr/local
}

function installHadoop {
    if resourceExists $HADOOP_ARCHIVE; then
        installLocalHadoop
    else
        installRemoteHadoop
    fi
    sudo ln -s /usr/local/$HADOOP_VERSION /usr/local/hadoop
}

function configHadoop {
    echo "creating hadoop directories"
    sudo mkdir /var/hadoop

    sudo chown vagrant /var/hadoop
    sudo chown -R vagrant /usr/local/$HADOOP_VERSION
    
    mkdir /var/hadoop/hadoop-datanode
    mkdir /var/hadoop/hadoop-namenode
    mkdir /var/hadoop/mr-history
    mkdir /var/hadoop/mr-history/done
    mkdir /var/hadoop/mr-history/tmp
    
    echo "copying over hadoop configuration files"
    sudo cp -f $HADOOP_RES_DIR/* $HADOOP_CONF

    echo "creating hadoop environment variables"
    sudo cp -f $HADOOP_RES_DIR/hadoop.sh /etc/profile.d/hadoop.sh
    . /etc/profile.d/hadoop.sh
}

function formatHdfs {
    echo "formatting HDFS"
    hdfs namenode -format
}

function startDaemons {
    echo "starting Hadoop daemons"
    
    $HADOOP_PREFIX/sbin/start-dfs.sh
    $HADOOP_PREFIX/sbin/start-yarn.sh
    
    echo "waiting for HDFS to come up"
    # loop until at least HDFS is up
    cmd="hdfs dfs -ls /"
    NEXT_WAIT_TIME=0
    up=0
    while [  $NEXT_WAIT_TIME -ne 4 ] ; do
        $cmd
        rc=$?
        if [[ $rc == 0 ]]; then
            up=1
            break
        fi
       sleep $(( NEXT_WAIT_TIME++ ))
    done

    if [[ $up != 1 ]]; then
        echo "HDFS doesn't seem to be up; exiting"
        exit $rc
    fi

    echo "listing all Java processes"
    /usr/local/java/bin/jps
}

function setupHdfs {
    echo "creating user home directory in hdfs"
    hdfs dfs -mkdir -p /user/root
    hdfs dfs -mkdir -p /user/vagrant
    hdfs dfs -chown vagrant /user/vagrant

    echo "creating temp directories in hdfs"
    hdfs dfs -mkdir -p /tmp
    hdfs dfs -chmod -R 777 /tmp

    hdfs dfs -mkdir -p /var
    hdfs dfs -chmod -R 777 /var
}

function setupHadoop {
    echo "setup hadoop: $1"

    installHadoop
    configHadoop

    if [[ "$1" == "master" ]]; then
        formatHdfs
        startDaemons
        setupHdfs
    fi

    echo "hadoop setup complete"
}

