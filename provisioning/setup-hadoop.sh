#!/bin/bash

function installLocalHadoop {
    echo "install hadoop from local file"
    FILE=/vagrant/resources/$HADOOP_ARCHIVE
    tar -xzf $FILE -C /usr/local
}

function installRemoteHadoop {
    echo "install hadoop from remote file"
    curl -sS -o /vagrant/resources/$HADOOP_ARCHIVE -O -L $HADOOP_MIRROR_DOWNLOAD
    tar -xzf /vagrant/resources/$HADOOP_ARCHIVE -C /usr/local
}

function configHadoop {
    echo "creating hadoop directories"
    mkdir /var/hadoop
    mkdir /var/hadoop/hadoop-datanode
    mkdir /var/hadoop/hadoop-namenode
    mkdir /var/hadoop/mr-history
    mkdir /var/hadoop/mr-history/done
    mkdir /var/hadoop/mr-history/tmp
    
    echo "copying over hadoop configuration files"
    cp -f $HADOOP_RES_DIR/* $HADOOP_CONF
}

function setupEnvVars {
    echo "creating hadoop environment variables"
    cp -f $HADOOP_RES_DIR/hadoop.sh /etc/profile.d/hadoop.sh
    . /etc/profile.d/hadoop.sh
}

function installHadoop {
    if resourceExists $HADOOP_ARCHIVE; then
        installLocalHadoop
    else
        installRemoteHadoop
    fi
    ln -s /usr/local/$HADOOP_VERSION /usr/local/hadoop
}

function formatHdfs {
    echo "formatting HDFS"
    hdfs namenode -format
}

function startDaemons {
    echo "starting Hadoop daemons"
    
    $HADOOP_PREFIX/sbin/start-all.sh
    
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
    jps
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
    echo "setup hadoop"

    installHadoop
    configHadoop
    setupEnvVars
    formatHdfs
    startDaemons
    setupHdfs

    echo "hadoop setup complete"
}

