#!/bin/bash
#KEY FILE AND USER TO CONNECT TO MASTER NODE
export KEY=$1
export USER=$2
export MASTERIP=$3
export MASTERLOCALIP=$4
export WORKER1IP=$5
export WORKER2IP=$6
export CEPHADMIN=192.168.50.246

#SET NAMESERVER
echo "Adding Nameservers"
mv /etc/resolv.conf /etc/resolve.bk
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.8.6" >> /etc/resolv.conf
cat /etc/resolve.bk >> /etc/resolv.conf

#HOSTS
echo "Adding Hostnames"
sudo cp /dev/null /etc/hosts
sudo cp /dev/null /etc/hosts.add
echo "$MASTERLOCALIP master-full" >> /etc/hosts.add
echo "$WORKER1IP worker-1-full" >> /etc/hosts.add
echo "$WORKER2IP worker-2-full" >> /etc/hosts.add
echo "127.0.0.1 localhost" >> /etc/hosts.add
echo "$CEPHADMIN ceph-admin-node" >> /etc/hosts.add
echo "$CEPHADMIN test.ceph-admin-node" >> /etc/hosts.add
echo "$CEPHADMIN test1.ceph-admin-node" >> /etc/hosts.add
cat /etc/hosts.add > ~/hosts
cat /etc/hosts >> ~/hosts
mv ~/hosts /etc/hosts


echo "Setting passless login to slaves"
#PASSWORDLESS LOGIN TO worker-1-full
cat /home/$USER/.ssh/id_rsa.pub | ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
#PASSWORDLESS LOGIN TO worker-2-full
cat /home/$USER/.ssh/id_rsa.pub | ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"


#COPY KEY TO SLAVES
echo "Copy key to OSDs"
scp -i "/home/$USER/$KEY" "/home/$USER/$KEY" "$USER"@"$WORKER1IP":~
scp -i "/home/$USER/$KEY" "/home/$USER/$KEY" "$USER"@"$WORKER2IP":~

#PASSLESS LOGIN WORKER-1-FULL TO ITSELF and OTHERS
echo "Setting passless login for worker-1-full"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'StrictHostKeyChecking no' > ~/.ssh/config && if [ ! -f /home/$USER/.ssh/id_rsa ]; then ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''; fi && cat ~/.ssh/id_rsa.pub >>  ~/.ssh/authorized_keys"
echo "Step1"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "cat /home/$USER/.ssh/id_rsa.pub | ssh -i /home/$USER/$KEY $USER@$MASTERLOCALIP 'mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys'"
echo "Step2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "cat /home/$USER/.ssh/id_rsa.pub | ssh -i /home/$USER/$KEY $USER@$WORKER2IP 'mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys'"

#PASSLESS LOGIN WORKER-2-FULL TO ITSELF and OTHERS
echo "Setting passless login for worker-2-full"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'StrictHostKeyChecking no' > ~/.ssh/config && if [ ! -f /home/$USER/.ssh/id_rsa ]; then ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''; fi && cat ~/.ssh/id_rsa.pub >>  ~/.ssh/authorized_keys"
echo "Step1"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "cat /home/$USER/.ssh/id_rsa.pub | ssh -i /home/$USER/$KEY $USER@$MASTERLOCALIP 'mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys'"
echo "Step2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "cat /home/$USER/.ssh/id_rsa.pub | ssh -i /home/$USER/$KEY $USER@$WORKER1IP 'mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys'"

#COPY HOSTS TO OSDS
echo "Adding Hostnames for slaves"
scp -i "/home/$USER/$KEY" /etc/hosts.add "$USER"@"$WORKER1IP":~
scp -i "/home/$USER/$KEY" /etc/hosts.add "$USER"@"$WORKER2IP":~
echo "Adding Hostnames for worker-1-full"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "touch ~/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo cp /dev/null /etc/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "cat ~/hosts.add >> /etc/hosts"


echo "Adding Hostnames for worker-2-full"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "touch ~/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo cp /dev/null /etc/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "cat ~/hosts.add >> /etc/hosts"

echo "Setting Nameservers for worker-1-full"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "touch ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'nameserver 8.8.8.8' > ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'nameserver 8.8.8.6' >> ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo cat /etc/resolv.conf >> /home/$USER/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo mv /home/$USER/resolv.conf /etc/resolv.conf"
echo "Setting Nameservers for worker-2-full"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "touch ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'nameserver 8.8.8.8' > ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'nameserver 8.8.8.6' >> ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo cat /etc/resolv.conf >> /home/$USER/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo mv /home/$USER/resolv.conf /etc/resolv.conf"


#INSTALL JAVA IN MASTER AND SLAVES
sudo apt-get update && echo 'Y' | sudo apt-get install default-jdk
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo apt-get update"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'Y' | sudo apt-get install default-jdk"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo apt-get update"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'Y' | sudo apt-get install default-jdk"

#MASTER-FULL
echo "Setting up Hadoop"
rm -rf hadoop-2.2.0*

#INSTALL HADOOP
wget https://archive.apache.org/dist/hadoop/core/hadoop-2.2.0/hadoop-2.2.0.tar.gz
tar xfz hadoop-2.2.0.tar.gz
sudo chmod -R 0777 hadoop-2.2.0
update-alternatives --config java

echo '#HADOOP VARIABLES START' >> ~/.bashrc 
echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> ~/.bashrc
echo 'export HADOOP_INSTALL=/home/cloud-user/hadoop-2.2.0' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' >> ~/.bashrc
echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL' >> ~/.bashrc
echo 'export YARN_HOME=$HADOOP_INSTALL' >> ~/.bashrc
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> ~/.bashrc
echo 'export HADOOP_OPTS='-Djava.library.path=$HADOOP_INSTALL/lib'' >> ~/.bashrc
echo '#HADOOP VARIABLES END' >> ~/.bashrc
source ~/.bashrc

echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> /etc/enviroment
echo 'export HADOOP_INSTALL=/home/cloud-user/hadoop-2.2.0' >> /etc/enviroment
echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' >> /etc/enviroment
echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' >> /etc/enviroment
echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' >> /etc/enviroment
echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL' >> /etc/enviroment
echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL' >> /etc/enviroment
echo 'export YARN_HOME=$HADOOP_INSTALL' >> /etc/enviroment
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> /etc/enviroment
echo 'export HADOOP_OPTS='-Djava.library.path=$HADOOP_INSTALL/lib'' >> /etc/enviroment


echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hadoop-env.sh

rm -rf /mnt/namenode
rm -rf /mnt/datanode
mkdir -p /mnt/namenode
chmod +x /mnt/namenode
mkdir -p /mnt/datanode
chmod +x /mnt/datanode


sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '		<name>fs.defaultFS</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '		<value>hdfs://master-full:54310</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '		<final>true</final>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '		<name>fs.s3n.awsAccessKeyId</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '		<value>123</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '		<name>fs.s3n.awsSecretAccessKey</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '		<value>456</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml
echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml

sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '		<name>yarn.nodemanager.aux-services</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '		<value>mapreduce_shuffle</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '		<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '		<value>org.apache.hadoop.mapred.ShuffleHandler</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml
echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml

cp /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml.template /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml

sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml
echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml
echo '		<name>mapreduce.framework.name</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml
echo '		<value>yarn</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml
echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml


sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '		<name>dfs.replication</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '		<value>3</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '		<name>dfs.namenode.name.dir</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '		<value>file:/mnt/namenode</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '		<name>dfs.datanode.data.dir</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '		<value>file:/mnt/datanode</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '		<name>dfs.block.size</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '		<value>33554432</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml
echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml

sudo cp /dev/null /home/$USER/hadoop-2.2.0/etc/hadoop/slaves
echo 'master-full' >> /home/$USER/hadoop-2.2.0/etc/hadoop/slaves
echo 'worker-1-full' >> /home/$USER/hadoop-2.2.0/etc/hadoop/slaves
echo 'worker-2-full' >> /home/$USER/hadoop-2.2.0/etc/hadoop/slaves
rm -rf /home/$USER/hadoop-2.2.0/share/hadoop/common/lib/jets3t-0.6.1.jar
scp -i "/home/$USER/$KEY" jets3t-0.6.1.jar /home/$USER/hadoop-2.2.0/share/hadoop/common/lib/
chmod 0777 /home/$USER/hadoop-2.2.0/share/hadoop/common/lib/jets3t-0.6.1.jar
chown $USER:$USER /home/$USER/hadoop-2.2.0/share/hadoop/common/lib/jets3t-0.6.1.jar



#WORKER-1-FULL
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "rm -rf hadoop-2.2.0*"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "wget https://archive.apache.org/dist/hadoop/core/hadoop-2.2.0/hadoop-2.2.0.tar.gz"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "tar xfz hadoop-2.2.0.tar.gz"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo chmod -R 0777 hadoop-2.2.0"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "update-alternatives --config java"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '#HADOOP VARIABLES START' >> ~/.bashrc" 
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export HADOOP_INSTALL=/home/cloud-user/hadoop-2.2.0' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export PATH=\$PATH:\$HADOOP_INSTALL/bin' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export PATH=\$PATH:\$HADOOP_INSTALL/sbin' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export HADOOP_COMMON_HOME=\$HADOOP_INSTALL' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export HADOOP_HDFS_HOME=\$HADOOP_INSTALL' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export YARN_HOME=\$HADOOP_INSTALL' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_INSTALL/lib/native' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export HADOOP_OPTS='-Djava.library.path=\$HADOOP_INSTALL/lib'' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '#HADOOP VARIABLES END' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "source ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hadoop-env.sh"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>fs.defaultFS</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>hdfs://master-full:54310</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<final>true</final>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>fs.s3n.awsAccessKeyId</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>123</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>fs.s3n.awsSecretAccessKey</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>456</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>yarn.nodemanager.aux-services</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>mapreduce_shuffle</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>org.apache.hadoop.mapred.ShuffleHandler</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "cp /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml.template /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>mapreduce.framework.name</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>yarn</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo rm -rf /mnt/datanode"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo mkdir -p /mnt/datanode"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo chmod 0777 /mnt/datanode"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo chown $USER:$USER /mnt/datanode"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>dfs.replication</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>3</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>dfs.namenode.name.dir</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>file:/mnt/namenode</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>dfs.datanode.data.dir</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>file:/mnt/datanode</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<name>dfs.block.size</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '		<value>33554432</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "rm -rf /home/$USER/hadoop-2.2.0/share/hadoop/common/lib/jets3t-0.6.1.jar"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "scp -r -i "/home/$USER/$KEY" "$USER"@"$MASTERLOCALIP":"/home/$USER/hadoop-2.2.0/share/hadoop/common/lib/jets3t-0.6.1.jar" /home/$USER/hadoop-2.2.0/share/hadoop/common/lib/"


#WORKER-2-FULL
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "rm -rf hadoop-2.2.0*"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "wget https://archive.apache.org/dist/hadoop/core/hadoop-2.2.0/hadoop-2.2.0.tar.gz"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "tar xfz hadoop-2.2.0.tar.gz"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo chmod -R 0777 hadoop-2.2.0"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "update-alternatives --config java"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '#HADOOP VARIABLES START' >> ~/.bashrc" 
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export HADOOP_INSTALL=/home/cloud-user/hadoop-2.2.0' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export PATH=\$PATH:\$HADOOP_INSTALL/bin' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export PATH=\$PATH:\$HADOOP_INSTALL/sbin' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export HADOOP_COMMON_HOME=\$HADOOP_INSTALL' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export HADOOP_HDFS_HOME=\$HADOOP_INSTALL' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export YARN_HOME=\$HADOOP_INSTALL' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_INSTALL/lib/native' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export HADOOP_OPTS='-Djava.library.path=\$HADOOP_INSTALL/lib'' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '#HADOOP VARIABLES END' >> ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "source ~/.bashrc"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hadoop-env.sh"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>fs.defaultFS</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>hdfs://master-full:54310</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<final>true</final>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>fs.s3n.awsAccessKeyId</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>123</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>fs.s3n.awsSecretAccessKey</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>456</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/core-site.xml"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>yarn.nodemanager.aux-services</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>mapreduce_shuffle</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>org.apache.hadoop.mapred.ShuffleHandler</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/yarn-site.xml"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "cp /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml.template /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>mapreduce.framework.name</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>yarn</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/mapred-site.xml"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo rm -rf /mnt/datanode"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo mkdir -p /mnt/datanode"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo chmod 0777 /mnt/datanode"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo chown $USER:$USER /mnt/datanode"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sed -i '/<configuration>/,/<\/configuration>/d' /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '<configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>dfs.replication</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>3</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>dfs.namenode.name.dir</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>file:/mnt/namenode</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>dfs.datanode.data.dir</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>file:/mnt/datanode</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	<property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<name>dfs.block.size</name>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '		<value>33554432</value>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '	</property>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '</configuration>' >> /home/$USER/hadoop-2.2.0/etc/hadoop/hdfs-site.xml"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "rm -rf /home/$USER/hadoop-2.2.0/share/hadoop/common/lib/jets3t-0.6.1.jar"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "scp -r -i "/home/$USER/$KEY" "$USER"@"$MASTERLOCALIP":"/home/$USER/hadoop-2.2.0/share/hadoop/common/lib/jets3t-0.6.1.jar" /home/$USER/hadoop-2.2.0/share/hadoop/common/lib/"

#FORMAT NAMENODE AND START
echo 'Y' | /home/$USER/hadoop-2.2.0/bin/hadoop namenode -format
chmod 0777 /mnt/namenode 
chown -R $USER:$USER /mnt/namenode
chmod 0777 /mnt/datanode
chown -R $USER:$USER /mnt/datanode













