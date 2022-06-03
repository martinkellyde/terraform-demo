#!/bin/bash

####################################################
#
# BEGIN STANDARD USERDATA
#
####################################################

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'
echo END

# Update the MOTD

cat > /etc/motd <<EOL

####################################################

        IMMUTABLE SERVER, DO NOT PATCH WITH YUM

     1. Create new AMI with packer
     2. Update the versions file, 
     3. Apply new config with terraform.

####################################################

EOL

# Clean up all but the latest kernel
sudo package-cleanup -y --oldkernels --count=1


####################################################
#
# This Jenkins install uses EFS to decouple state for HA
#
####################################################

# Configure EFS
yum install -y amazon-efs-utils
mkdir /mnt/efs
mount -t efs -o tls ${efs_id}:/ /mnt/efs
mkdir /mnt/efs/jenkins

# Install Jenkins
yum update –y
yum remove -y java-1.7.0-openjdk
yum install -y java-1.8.0
yum install git

wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
yum install jenkins -y
chown jenkins.jenkins /mnt/efs/jenkins
## Set Jenkins Home before we start Jenkins
sed -i 's/\/var\/lib\/jenkins/\/mnt\/efs\/jenkins/g' /etc/sysconfig/jenkins
chkconfig jenkins on
service jenkins start
