# pseudodistributed-hadoop-docker
Apache Hadoop 2.7.2 Docker image in pseudo-distributed mode

This is a pre-configured single-node Hadoop image that allows you to quickly perform simple operations using Hadoop MapReduce and the Hadoop Distributed File System (HDFS). 

It is based on the guide writen by Juan Alonso Ramos, [First steps with Hadoop](http://www.adictosaltrabajo.com/tutoriales/hadoop-first-steps/), with some corrections applied. It is also based on [@sequenceiq/hadoop-docker](https://github.com/sequenceiq/hadoop-docker)

## How to use?
1. Clone the repo
2. Build the image
3. Start a new container based on the image
4. Run /etc/hadoop_init.sh, it will
 * setup env variables
 * format the filesystem (HDFS)
 * initialize all the necessary daemons to start operating
5. Start running some Hadoop MR code!

## How can I build the image?
You can build the image as:
```
docker build -t glmarmar/hadoop:2.7.2 .
```

## How can I start a container?
To use the image you have just build use:
```
docker run -it -P glmarmar/hadoop:2.7.2
```
*Note: With -P option you're publishing all exposed ports to random ports. To discover on which ports it is mapping, you can use Kitematic or:*
```
docker ps
```
Once you start a container It will automatically start a bash shell and log in as "Hadoop" user.
