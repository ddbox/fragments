#!/bin/bash
#installs docker on SL7 machine
#tested on fermicloud

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
cd /etc/yum.repos.d
#yum-config-manager --add-repo https://jobsub.fnal.gov/other/centos.repo
#yum-config-manager --add-repo https://fermicloud042.fnal.gov/centos.repo
yum-config-manager --add-repo https://raw.githubusercontent.com/ddbox/fragments/master/centos.repo
yum makecache fast
yum -y install docker-ce
systemctl start docker
#usermod -aG docker dbox

