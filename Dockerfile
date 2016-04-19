FROM ubuntu
MAINTAINER Gregorio L. Marmol Martinez <glmarmar@alu.upo.es>

USER root

ENV DEBIAN_FRONTEND noninteractive

# install dependencies

RUN apt-get update && apt-get install -y curl ssh openssh-server rsync

# java

RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.tar.gz' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN tar -xvzf jdk-*.tar.gz && rm jdk-*.tar.gz
RUN mkdir /usr/lib/jvm && mv jdk1.7.0_71 /usr/lib/jvm

RUN update-alternatives --install "/usr/bin/java" "java" \
    "/usr/lib/jvm/jdk1.7.0_71/bin/java" 1

RUN update-alternatives --install "/usr/bin/javac" "javac" \
    "/usr/lib/jvm/jdk1.7.0_71/bin/javac" 1

RUN update-alternatives --install "/usr/bin/javaws" "javaws" \
    "/usr/lib/jvm/jdk1.7.0_71/bin/javaws" 1

RUN update-alternatives --install "/usr/bin/jps" "jps" \
    "/usr/lib/jvm/jdk1.7.0_71/bin/jps" 1

RUN update-alternatives --install "/usr/bin/jar" "jar" \
    "/usr/lib/jvm/jdk1.7.0_71/bin/jar" 1

RUN update-alternatives --config java

# disable ipv6

RUN echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
RUN echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
RUN echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
RUN sysctl -p /etc/sysctl.conf

# hadoop

RUN wget http://apache.rediris.es/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz
RUN tar xvzf hadoop-*.tar.gz && rm hadoop-*.tar.gz
RUN mv hadoop-* /usr/local/ && mv /usr/local/hadoop-* /usr/local/hadoop

# hadoop config

ENV JAVA_HOME /usr/lib/jvm/jdk1.7.0_71/
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME ${HADOOP_HOME}
ENV HADOOP_COMMON_HOME ${HADOOP_HOME}
ENV HADOOP_HDFS_HOME ${HADOOP_HOME}
ENV YARN_HOME ${HADOOP_HOME}
ENV PATH $PATH:$HADOOP_HOME/bin
ENV PATH $PATH:$HADOOP_HOME/sbin

ADD core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
ADD yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml

RUN sed -i "/^export JAVA_HOME/ s:.*:export JAVA_HOME=$JAVA_HOME\n:" /usr/local/hadoop/etc/hadoop/hadoop-env.sh

# hadoop user & ssh config

RUN useradd -m hadoop
RUN echo "hadoop:123456" | chpasswd
RUN usermod -aG sudo hadoop
RUN usermod -s /bin/bash hadoop

RUN chown -R hadoop /usr/local/hadoop/

RUN mkdir /var/run/sshd

USER hadoop

RUN mkdir ~/.ssh && chmod 0700 /home/hadoop/.ssh
RUN ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -N '' && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

RUN mkdir /home/hadoop/workspace
RUN mkdir /home/hadoop/workspace/dfs
RUN mkdir /home/hadoop/workspace/dfs/name
RUN mkdir /home/hadoop/workspace/dfs/data
RUN mkdir /home/hadoop/workspace/mapred
RUN mkdir /home/hadoop/workspace/mapred/system
RUN mkdir /home/hadoop/workspace/mapred/local

# ending

USER root
ADD hadoop_init.sh /etc/hadoop_init.sh
RUN chmod +x /etc/hadoop_init.sh

# copying examples

ADD wordcount_example/ /home/hadoop/wordcount_example/
RUN chown -R hadoop:hadoop /home/hadoop/wordcount_example/

CMD service ssh start && su hadoop && bash

# hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# mapred ports
EXPOSE 19888
# yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
# other ports
EXPOSE 49707
