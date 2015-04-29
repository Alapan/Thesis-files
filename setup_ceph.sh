#!/bin/bash
export KEY=$1
export USER=$2
export CEPHADMINIP=$3
export CEPHADMINLOCALIP=$4
export CEPHOSD1IP=$5
export CEPHOSD2IP=$6
export CEPHVERSION=firefly

echo "Installing $CEPHVERSION to $CEPHADMINLOCALIP"

#SET NAMESERVER
echo "Adding Nameservers"
mv /etc/resolv.conf /etc/resolve.bk
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.8.6" >> /etc/resolv.conf
cat /etc/resolve.bk >> /etc/resolv.conf

#HOSTS
echo "Adding Hostnames"
#mv /etc/hosts /etc/hosts.bk
echo "$CEPHADMINLOCALIP ceph-admin" > /etc/hosts.add
echo "$CEPHADMINLOCALIP test.ceph-admin" >> /etc/hosts.add
echo "$CEPHADMINLOCALIP *.ceph-admin" >> /etc/hosts.add
echo "$CEPHOSD1IP ceph-osd1" >> /etc/hosts.add
echo "$CEPHOSD2IP ceph-osd2" >> /etc/hosts.add
cat /etc/hosts.add > ~/hosts
cat /etc/hosts >> ~/hosts
mv ~/hosts /etc/hosts

#PREFLIGHT
wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | apt-key add -
echo deb http://ceph.com/debian-${CEPHVERSION}/ $(lsb_release -sc) main | tee /etc/apt/sources.list.d/ceph.list
apt-get update && echo 'Y' | sudo apt-get install ceph-deploy
echo 'Y' | apt-get install ntp
echo 'Y' | apt-get install openssh-server

echo "Setting passless login to osds"
#PASSLESS LOGIN TO OSD1
cat /home/$USER/.ssh/id_rsa.pub | ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
#PASSLESS LOGIN TO OSD2
cat /home/$USER/.ssh/id_rsa.pub | ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "echo 'Y' | sudo apt-get install ntp"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "echo 'Y' | sudo apt-get install openssh-server"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "echo 'Y' | sudo apt-get install ntp"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "echo 'Y' | sudo apt-get install openssh-server"

#COPY KEY TO OSDS
echo "Copy key to OSDs"
scp -i "/home/$USER/$KEY" "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP":~
scp -i "/home/$USER/$KEY" "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP":~

#PASSLESS LOGIN OSD1 TO ITSELF and OTHERS
echo "Setting passless login for osd1"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "echo 'StrictHostKeyChecking no' > ~/.ssh/config && if [ ! -f /home/$USER/.ssh/id_rsa ]; then ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''; fi && cat ~/.ssh/id_rsa.pub >>  ~/.ssh/authorized_keys"
echo "Step1"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "cat /home/$USER/.ssh/id_rsa.pub | ssh -i /home/$USER/$KEY $USER@$CEPHADMINLOCALIP 'mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys'"
echo "Step2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "cat /home/$USER/.ssh/id_rsa.pub | ssh -i /home/$USER/$KEY $USER@$CEPHOSD2IP 'mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys'"
#PASSLESS LOGIN OSD2 TO ITSELF and OTHERS
echo "Setting passless login for osd2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "echo 'StrictHostKeyChecking no' > ~/.ssh/config && if [ ! -f /home/$USER/.ssh/id_rsa ]; then ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''; fi && cat ~/.ssh/id_rsa.pub >>  ~/.ssh/authorized_keys"
echo "Step1"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "cat /home/$USER/.ssh/id_rsa.pub | ssh -i /home/$USER/$KEY $USER@$CEPHADMINLOCALIP 'mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys'"
echo "Step2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "cat /home/$USER/.ssh/id_rsa.pub | ssh -i /home/$USER/$KEY $USER@$CEPHOSD1IP 'mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys'"

#COPY HOSTS TO OSDS
echo "Adding Hostnames for OSDs"
scp -i "/home/$USER/$KEY" /etc/hosts.add "$USER"@"$CEPHOSD1IP":~
scp -i "/home/$USER/$KEY" /etc/hosts.add "$USER"@"$CEPHOSD2IP":~
echo "Adding Hostnames for OSD1"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "touch ~/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "cat ~/hosts.add > ~/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "sudo cat /etc/hosts >> /home/$USER/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "sudo mv /home/$USER/hosts /etc/hosts"
echo "Adding Hostnames for OSD2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "touch ~/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "cat ~/hosts.add > ~/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "sudo cat /etc/hosts >> /home/$USER/hosts"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "sudo mv /home/$USER/hosts /etc/hosts"

echo "Setting Nameservers for OSD1"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "touch ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "echo 'nameserver 8.8.8.8' > ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "echo 'nameserver 8.8.8.6' >> ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "sudo cat /etc/resolv.conf >> /home/$USER/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "sudo mv /home/$USER/resolv.conf /etc/resolv.conf"
echo "Setting Nameservers for OSD2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "touch ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "echo 'nameserver 8.8.8.8' > ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "echo 'nameserver 8.8.8.6' >> ~/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "sudo cat /etc/resolv.conf >> /home/$USER/resolv.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "sudo mv /home/$USER/resolv.conf /etc/resolv.conf"

#SETUP CEPH


echo "Setting up CEPH"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "rm -rf my-cluster"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "mkdir my-cluster"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy purge ceph-admin ceph-osd1 ceph-osd2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy purgedata ceph-admin ceph-osd1 ceph-osd2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy forgetkeys"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy new ceph-admin"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && echo 'osd pool default size = 2' >> ceph.conf"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy install ceph-admin ceph-osd1 ceph-osd2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy mon create-initial"

ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "ssh ceph-osd1 'sudo mkdir -p /mnt/local/osd1/'"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "ssh ceph-osd2 'sudo mkdir -p /mnt/local/osd2/'"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd prepare ceph-osd1:/mnt/local/osd1/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd prepare ceph-osd2:/mnt/local/osd2/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd activate ceph-osd1:/mnt/local/osd1/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd activate ceph-osd1:/mnt/local/osd1/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd activate ceph-osd2:/mnt/local/osd2/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd activate ceph-osd2:/mnt/local/osd2/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy admin ceph-admin ceph-admin ceph-osd1 ceph-osd2"
chmod +r /etc/ceph/ceph.client.admin.keyring
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy mds create ceph-admin"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy mon create ceph-osd1 ceph-osd2"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "ssh ceph-admin 'sudo mkdir -p /mnt/local/osd0/'"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd prepare ceph-admin:/mnt/local/osd0/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd activate ceph-admin:/mnt/local/osd0/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy osd activate ceph-admin:/mnt/local/osd0/"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph health"

#SETUP RADOS
wget -q -O- https://raw.github.com/ceph/ceph/master/keys/autobuild.asc | apt-key add -
echo deb http://gitbuilder.ceph.com/apache2-deb-$(lsb_release -sc)-x86_64-basic/ref/master $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph-apache.list
echo deb http://gitbuilder.ceph.com/libapache-mod-fastcgi-deb-$(lsb_release -sc)-x86_64-basic/ref/master $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph-fastcgi.list
apt-get update && echo 'Y' | apt-get install apache2 libapache2-mod-fastcgi
echo "ServerName $(hostname -f)" >> /etc/apache2/apache2.conf
a2enmod rewrite
a2enmod fastcgi
service apache2 restart
echo 'Y' | apt-get install radosgw
echo 'Y' | apt-get install radosgw-agent
echo "[client.radosgw.gateway]">> /home/$USER/my-cluster/ceph.conf
echo "        host = ceph-admin">> /home/$USER/my-cluster/ceph.conf
echo "        keyring = /etc/ceph/keyring.radosgw.gateway">> /home/$USER/my-cluster/ceph.conf
echo "        rgw socket path = /tmp/radosgw.sock">> /home/$USER/my-cluster/ceph.conf
echo "        log file = /var/log/ceph/radosgw.log">> /home/$USER/my-cluster/ceph.conf
echo "        rgw dns name = ceph-admin">> /home/$USER/my-cluster/ceph.conf
cp /home/$USER/my-cluster/ceph.conf /etc/ceph/ceph.conf
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "cd my-cluster && ceph-deploy --overwrite-conf config push ceph-admin ceph-osd1 ceph-osd2"
mkdir -p /var/lib/ceph/radosgw/ceph-radosgw.gateway
mkdir -p /var/lib/ceph/radosgw/client.radosgw.gateway
echo "FastCgiExternalServer /var/www/s3gw.fcgi -socket /tmp/radosgw.sock" > /etc/apache2/sites-available/rgw.conf
echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/rgw.conf
echo "        ServerName ceph-admin" >> /etc/apache2/sites-available/rgw.conf
echo "        ServerAlias *.ceph-admin" >> /etc/apache2/sites-available/rgw.conf
echo "        ServerAdmin admin@admin.admin" >> /etc/apache2/sites-available/rgw.conf
echo "        DocumentRoot /var/www" >> /etc/apache2/sites-available/rgw.conf
echo "        RewriteEngine On" >> /etc/apache2/sites-available/rgw.conf
echo "        RewriteRule ^/([a-zA-Z0-9-_.]*)([/]?.*) /s3gw.fcgi?page=$1&params=$2&%{QUERY_STRING} [E=HTTP_AUTHORIZATION:%{HTTP:Authorization},L]" >> /etc/apache2/sites-available/rgw.conf
echo "        <IfModule mod_fastcgi.c>" >> /etc/apache2/sites-available/rgw.conf
echo "                <Directory /var/www>" >> /etc/apache2/sites-available/rgw.conf
echo "                        Options +ExecCGI" >> /etc/apache2/sites-available/rgw.conf
echo "                        AllowOverride All" >> /etc/apache2/sites-available/rgw.conf
echo "                        SetHandler fastcgi-script" >> /etc/apache2/sites-available/rgw.conf
echo "                        Order allow,deny" >> /etc/apache2/sites-available/rgw.conf
echo "                        Allow from all" >> /etc/apache2/sites-available/rgw.conf
echo "                        AuthBasicAuthoritative Off" >> /etc/apache2/sites-available/rgw.conf
echo "                </Directory>" >> /etc/apache2/sites-available/rgw.conf
echo "        </IfModule>" >> /etc/apache2/sites-available/rgw.conf
echo "        AllowEncodedSlashes On" >> /etc/apache2/sites-available/rgw.conf
echo "        ErrorLog /var/log/apache2/error.log" >> /etc/apache2/sites-available/rgw.conf
echo "        CustomLog /var/log/apache2/access.log combined" >> /etc/apache2/sites-available/rgw.conf
echo "        ServerSignature Off" >> /etc/apache2/sites-available/rgw.confss
echo "</VirtualHost>" >> /etc/apache2/sites-available/rgw.conf
a2ensite rgw.conf
a2dissite 000-default
echo "#!/bin/sh" > /var/www/s3gw.fcgi
echo 'exec /usr/bin/radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway' > /var/www/s3gw.fcgi
chmod +x /var/www/s3gw.fcgi
ceph-authtool --create-keyring /etc/ceph/keyring.radosgw.gateway
chmod +r /etc/ceph/keyring.radosgw.gateway
ceph-authtool /etc/ceph/keyring.radosgw.gateway -n client.radosgw.gateway --gen-key
ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/keyring.radosgw.gateway
ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.radosgw.gateway -i /etc/ceph/keyring.radosgw.gateway

scp -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" /etc/ceph/keyring.radosgw.gateway "$USER"@"$CEPHADMINLOCALIP":~
scp -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" /etc/ceph/keyring.radosgw.gateway "$USER"@"$CEPHOSD1IP":~
scp -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" /etc/ceph/keyring.radosgw.gateway "$USER"@"$CEPHOSD2IP":~
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "sudo mv /home/$USER/keyring.radosgw.gateway /etc/ceph/keyring.radosgw.gateway"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD1IP" "sudo mv /home/$USER/keyring.radosgw.gateway /etc/ceph/keyring.radosgw.gateway"
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHOSD2IP" "sudo mv /home/$USER/keyring.radosgw.gateway /etc/ceph/keyring.radosgw.gateway"



service ceph restart
service apache2 restart
/etc/init.d/radosgw start

sleep 30
ssh -o "StrictHostKeyChecking no" -i "/home/$USER/$KEY" "$USER"@"$CEPHADMINLOCALIP" "radosgw-admin user create --uid=johndoe --display-name=\"John Doe\" --email=john@example.com --access-key=123 --secret=456 --access=full"

