#!/bin/bash
#KEY FILE AND USER TO CONNECT TO CEPH-ADMIN
export KEY=poutakey.pem
export USER=cloud-user
export CEPHADMINIP=86.50.168.111
export CEPHADMINLOCALIP=192.168.50.246
export CEPHOSD1IP=192.168.50.247
export CEPHOSD2IP=192.168.50.248

#COPYKEY TO CEPH-ADMIN
scp -i $KEY $KEY "$USER"@"$CEPHADMINIP":~
scp -i $KEY setup_ceph.sh "$USER"@"$CEPHADMINIP":~
ssh -i $KEY "$USER"@"$CEPHADMINIP" "chmod +x setup_ceph.sh"
ssh -i $KEY "$USER"@"$CEPHADMINIP" "echo 'StrictHostKeyChecking no' > ~/.ssh/config"
ssh -i $KEY "$USER"@"$CEPHADMINIP" "if [ ! -f /home/$USER/.ssh/id_rsa ]; then ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''; fi;"
ssh -i $KEY "$USER"@"$CEPHADMINIP" "cat ~/.ssh/id_rsa.pub >>  ~/.ssh/authorized_keys"
ssh -i $KEY "$USER"@"$CEPHADMINIP" "sudo ./setup_ceph.sh $KEY $USER $CEPHADMINIP $CEPHADMINLOCALIP $CEPHOSD1IP $CEPHOSD2IP"

