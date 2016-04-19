#!/bin/bash
PATH=$PATH:$HADOOP_HOME/bin
export PATH
$HADOOP_HOME/bin/hadoop namenode -format
$HADOOP_HOME/sbin/start-all.sh