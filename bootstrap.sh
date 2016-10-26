#!/bin/bash

: ${HADOOP_PREFIX:=/opt/hadoop}

# setup hadoop with non-localhost hostname/ip address
sed -i "s/localhost/$(hostname)/" $HADOOP_CONF_DIR/core-site.xml
$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# remove any pids
rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# setup accumulo with non-localhost hostname/ip address
#sed -i "s/localhost/$(hostname)/" $ZOOKEEPER_HOME/conf/zoo.cnf

# setup accumulo with non-localhost hostname/ip address
sed -i "s/localhost/$(hostname)/" $ACCUMULO_HOME/conf/core-site.xml
sed -i "s/localhost/$(hostname)/" $ACCUMULO_HOME/conf/gc
sed -i "s/localhost/$(hostname)/" $ACCUMULO_HOME/conf/masters
sed -i "s/localhost/$(hostname)/" $ACCUMULO_HOME/conf/monitor
sed -i "s/localhost/$(hostname)/" $ACCUMULO_HOME/conf/slaves
sed -i "s/localhost/$(hostname)/" $ACCUMULO_HOME/conf/tracers
#$ACCUMULO_HOME/conf/accumulo-env.sh

# start sshd
service sshd start

# star zookeeper
$ZOOKEEPER_HOME/bin/zkServer.sh start

# start hadoop
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/bin/hdfs dfsadmin -safemode wait
$HADOOP_PREFIX/sbin/start-yarn.sh

# initialize accumulo
$ACCUMULO_HOME/bin/accumulo init --instance-name accumulo --password secret

#$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# stop hadoop
$HADOOP_PREFIX/sbin/stop-yarn.sh
$HADOOP_PREFIX/sbin/stop-dfs.sh

# stop zookeeper
$ZOOKEEPER_HOME/bin/zkServer.sh stop

# stop sshd
service sshd stop

service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver
$ZOOKEEPER_HOME/bin/zkServer.sh start
$ACCUMULO_HOME/bin/start-all.sh

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

