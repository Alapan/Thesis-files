#!/bin/bash

export KEY=$1
export USER=$2
export MASTERIP=$3
export MASTERLOCALIP=$4
export WORKER1IP=$5
export WORKER2IP=$6
export TACHYONIP=$7

# set up tachyon in master-full
rm -rf tachyon-0.5.0/*
mkdir tachyon
chmod 0777 tachyon	
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$MASTERLOCALIP" "scp -r -i "/home/$USER/$KEY" "$USER"@"$TACHYONIP":"/home/$USER/tachyon-0.5.0/" tachyon"
cp -r tachyon/* /home/$USER/
rm -rf tachyon
sudo cp /dev/null /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '#!/usr/bin/env bash' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'if [[ `uname -a` == Darwin* ]]; then' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  export JAVA_HOME=${JAVA_HOME:-$(/usr/libexec/java_home)}' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  export TACHYON_RAM_FOLDER=/Volumes/ramdisk' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  export TACHYON_JAVA_OPTS="-Djava.security.krb5.realm= -Djava.security.krb5.kdc="' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'else' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  if [ -z "$JAVA_HOME" ]; then' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '    export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  fi' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  export TACHYON_RAM_FOLDER=/mnt/ramdisk' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'fi' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'export JAVA="$JAVA_HOME/bin/java"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'export TACHYON_MASTER_ADDRESS=master-full' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'export TACHYON_UNDERFS_ADDRESS=s3n://test/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'export TACHYON_WORKER_MEMORY_SIZE=500MB' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'export TACHYON_HDFS_IMPL=org.apache.hadoop.fs.s3native.NativeS3FileSystem' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'export TACHYON_JAVA_OPTS+="' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dlog4j.configuration=file:$CONF_DIR/log4j.properties' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.debug=false' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.underfs.address=$TACHYON_UNDERFS_ADDRESS' >>/home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.underfs.hdfs.impl=$TACHYON_UNDERFS_HDFS_IMPL' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.data.folder=/mnt/ramdisk/data' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.workers.folder=/mnt/ramdisk/workers' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.worker.memory.size=$TACHYON_WORKER_MEMORY_SIZE' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.worker.data.folder=$TACHYON_RAM_FOLDER/tachyonworker/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.master.worker.timeout.ms=60000' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.master.hostname=$TACHYON_MASTER_ADDRESS' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.master.journal.folder=$TACHYON_HOME/journal/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dorg.apache.jasper.compiler.disablejsr199=true' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dtachyon.user.default.block.size.byte=134217728' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Djava.net.preferIPv4Stack=true' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dfs.s3n.awsAccessKeyId=123' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '  -Dfs.s3n.awsSecretAccessKey=456' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo '"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'export TACHYON_MASTER_JAVA_OPTS="$TACHYON_JAVA_OPTS"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
echo 'export TACHYON_WORKER_JAVA_OPTS="$TACHYON_JAVA_OPTS"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh
sudo cp /dev/null /home/$USER/tachyon-0.5.0/conf/slaves
echo 'master-full' >> /home/$USER/tachyon-0.5.0/conf/slaves
echo 'worker-1-full' >> /home/$USER/tachyon-0.5.0/conf/slaves
echo 'worker-2-full' >> /home/$USER/tachyon-0.5.0/conf/slaves

# set up tachyon in worker-1-full

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "rm -rf tachyon-0.5.0*"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "mkdir tachyon"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo chmod 0777 tachyon"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "scp -r -i "/home/$USER/$KEY" "$USER"@"$TACHYONIP":"/home/$USER/tachyon-0.5.0/" tachyon"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "cp -r tachyon/* /home/$USER/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "rm -rf tachyon"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "sudo cp /dev/null /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '#!/usr/bin/env bash' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'if [[ \`uname -a\` == Darwin* ]]; then' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  export JAVA_HOME=\${JAVA_HOME:-\$(/usr/libexec/java_home)}' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  export TACHYON_RAM_FOLDER=/Volumes/ramdisk' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh" 
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  export TACHYON_JAVA_OPTS=\"-Djava.security.krb5.realm= -Djava.security.krb5.kdc=\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'else' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  if [ -z \"\$JAVA_HOME\" ]; then' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '    export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  fi' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  export TACHYON_RAM_FOLDER=/mnt/ramdisk' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'fi' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export JAVA=\"\$JAVA_HOME/bin/java\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export TACHYON_MASTER_ADDRESS=master-full' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export TACHYON_UNDERFS_ADDRESS=s3n://test/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export TACHYON_WORKER_MEMORY_SIZE=500MB' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export TACHYON_HDFS_IMPL=org.apache.hadoop.fs.s3native.NativeS3FileSystem' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'CONF_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export TACHYON_JAVA_OPTS+=\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dlog4j.configuration=file:\$CONF_DIR/log4j.properties' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.debug=false' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.underfs.address=\$TACHYON_UNDERFS_ADDRESS' >>/home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.underfs.hdfs.impl=\$TACHYON_UNDERFS_HDFS_IMPL' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.data.folder=/mnt/ramdisk/data' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.workers.folder=/mnt/ramdisk/workers' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.worker.memory.size=\$TACHYON_WORKER_MEMORY_SIZE' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.worker.data.folder=\$TACHYON_RAM_FOLDER/tachyonworker/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.master.worker.timeout.ms=60000' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.master.hostname=\$TACHYON_MASTER_ADDRESS' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.master.journal.folder=\$TACHYON_HOME/journal/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dorg.apache.jasper.compiler.disablejsr199=true' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dtachyon.user.default.block.size.byte=134217728' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Djava.net.preferIPv4Stack=true' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dfs.s3n.awsAccessKeyId=123' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '  -Dfs.s3n.awsSecretAccessKey=456' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo '\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export TACHYON_MASTER_JAVA_OPTS=\"\$TACHYON_JAVA_OPTS\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "echo 'export TACHYON_WORKER_JAVA_OPTS=\"\$TACHYON_JAVA_OPTS\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "chmod -R 0777 /home/$USER/tachyon-0.5.0"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER1IP" "chown -R $USER:$USER /home/$USER/tachyon-0.5.0"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo chmod -R 0777 /mnt/ramdisk"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo chown -R $USER:$USER /mnt/ramdisk"

#$( cd \"$( dirname \"${BASH_SOURCE[0]}

# set up tachyon in worker-2-full

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "rm -rf tachyon-0.5.0*"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "mkdir tachyon"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo chmod 0777 tachyon"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "scp -r -i "/home/$USER/$KEY" "$USER"@"$TACHYONIP":"/home/$USER/tachyon-0.5.0/" tachyon"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "cp -r tachyon/* /home/$USER/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "rm -rf tachyon"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo cp /dev/null /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '#!/usr/bin/env bash' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'if [[ \`uname -a\` == Darwin* ]]; then' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  export JAVA_HOME=\${JAVA_HOME:-\$(/usr/libexec/java_home)}' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  export TACHYON_RAM_FOLDER=/Volumes/ramdisk' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh" 
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  export TACHYON_JAVA_OPTS=\"-Djava.security.krb5.realm= -Djava.security.krb5.kdc=\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'else' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  if [ -z \"\$JAVA_HOME\" ]; then' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '    export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  fi' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  export TACHYON_RAM_FOLDER=/mnt/ramdisk' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'fi' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export JAVA=\"\$JAVA_HOME/bin/java\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export TACHYON_MASTER_ADDRESS=master-full' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export TACHYON_UNDERFS_ADDRESS=s3n://test/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export TACHYON_WORKER_MEMORY_SIZE=500MB' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export TACHYON_HDFS_IMPL=org.apache.hadoop.fs.s3native.NativeS3FileSystem' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'CONF_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export TACHYON_JAVA_OPTS+=\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dlog4j.configuration=file:\$CONF_DIR/log4j.properties' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.debug=false' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.underfs.address=\$TACHYON_UNDERFS_ADDRESS' >>/home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.underfs.hdfs.impl=\$TACHYON_UNDERFS_HDFS_IMPL' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.data.folder=/mnt/ramdisk/data' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.workers.folder=/mnt/ramdisk/workers' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.worker.memory.size=\$TACHYON_WORKER_MEMORY_SIZE' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.worker.data.folder=\$TACHYON_RAM_FOLDER/tachyonworker/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.master.worker.timeout.ms=60000' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.master.hostname=\$TACHYON_MASTER_ADDRESS' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.master.journal.folder=\$TACHYON_HOME/journal/' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dorg.apache.jasper.compiler.disablejsr199=true' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dtachyon.user.default.block.size.byte=134217728' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Djava.net.preferIPv4Stack=true' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dfs.s3n.awsAccessKeyId=123' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '  -Dfs.s3n.awsSecretAccessKey=456' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo '\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export TACHYON_MASTER_JAVA_OPTS=\"\$TACHYON_JAVA_OPTS\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "echo 'export TACHYON_WORKER_JAVA_OPTS=\"\$TACHYON_JAVA_OPTS\"' >> /home/$USER/tachyon-0.5.0/conf/tachyon-env.sh"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "chmod -R 0777 /home/$USER/tachyon-0.5.0"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "chown -R $USER:$USER /home/$USER/tachyon-0.5.0"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo chmod -R 0777 /mnt/ramdisk"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$WORKER2IP" "sudo chown -R $USER:$USER /mnt/ramdisk"

/home/$USER/tachyon-0.5.0/bin/tachyon format
#/home/$USER/tachyon-0.5.0/bin/tachyon-start.sh all SudoMount
chmod -R 0777 /home/$USER/tachyon-0.5.0
chown -R $USER:$USER /home/$USER/tachyon-0.5.0
sudo chmod -R 0777 /mnt/ramdisk
sudo chown -R $USER:$USER /mnt/ramdisk





