#!/bin/bash
#KEY FILE AND USER TO CONNECT TO MASTER NODE
export KEY=poutakey.pem
export USER=cloud-user
export MASTERIP=86.50.168.36
export MASTERLOCALIP=192.168.50.243
export WORKER1IP=192.168.50.244
export WORKER2IP=192.168.50.245
export TACHYONIP=86.50.169.10

#COPYKEY TO CEPH-ADMIN
scp -i $KEY $KEY "$USER"@"$MASTERIP":~
scp -i $KEY setup_tachyon.sh "$USER"@"$MASTERIP":~
ssh -i $KEY "$USER"@"$MASTERIP" "chmod +x setup_tachyon.sh"
#ssh -i $KEY "$USER"@"$MASTERIP" "echo 'StrictHostKeyChecking no' > ~/.ssh/config"
#ssh -i $KEY "$USER"@"$MASTERIP" "if [ ! -f /home/$USER/.ssh/id_rsa ]; then ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''; fi;"
#ssh -i $KEY "$USER"@"$MASTERIP" "cat ~/.ssh/id_rsa.pub >>  ~/.ssh/authorized_keys"
ssh -i $KEY "$USER"@"$MASTERIP" "sudo ./setup_tachyon.sh $KEY $USER $MASTERIP $MASTERLOCALIP $WORKER1IP $WORKER2IP $TACHYONIP"

