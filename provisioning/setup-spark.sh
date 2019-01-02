#!/bin/bash

# http://www.cloudera.com/content/cloudera/en/documentation/core/v5-2-x/topics/cdh_ig_spark_configure.html

source "/vagrant/provisioning/common.sh"

function installLocalSpark {
    echo "install spark from local file"
    FILE=/vagrant/resources/$SPARK_ARCHIVE
    sudo tar -xzf $FILE -C /usr/local
}

function installRemoteSpark {
    echo "install spark from remote file"
    sudo curl -sS -o /vagrant/resources/$SPARK_ARCHIVE -O -L $SPARK_MIRROR_DOWNLOAD
    sudo tar -xzf /vagrant/resources/$SPARK_ARCHIVE -C /usr/local
}

function installSpark {
    if resourceExists $SPARK_ARCHIVE; then
        installLocalSpark
    else
        installRemoteSpark
    fi
    sudo ln -s /usr/local/$SPARK_VERSION-bin-hadoop2.7 /usr/local/spark
    sudo mkdir -p /usr/local/spark/logs/history
}

function configSpark {
    echo "config spark"

    sudo chown -R vagrant /usr/local/$SPARK_VERSION-bin-hadoop2.7

    sudo cp -f /vagrant/provisioning/spark/slaves /usr/local/spark/conf
    sudo cp -f /vagrant/provisioning/spark/spark-env.sh /usr/local/spark/conf
    sudo cp -f /vagrant/provisioning/spark/spark-defaults.conf /usr/local/spark/conf

    echo "creating spark environment variables"
    sudo cp -f $SPARK_RES_DIR/spark.sh /etc/profile.d/spark.sh
    . /etc/profile.d/spark.sh
}


function setupHistoryServer {
    echo "setup history server"
    . /etc/profile.d/hadoop.sh
    hdfs dfs -mkdir -p /user/spark/applicationHistory
    hdfs dfs -chmod -R 777 /user/spark
}

function startSparkService {
    echo "starting Spark service"
    /usr/local/spark/sbin/start-master.sh
    /usr/local/spark/sbin/start-slaves.sh
}

function setupSpark {
    echo "setup spark"

    installSpark
    configSpark

    if [[ "$1" == "master" ]]; then
        setupHistoryServer
        startSparkService
    fi

    echo "spark setup complete"
}
