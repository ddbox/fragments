
crpm=centos-release-7-7.1908.0.el7.centos.x86_64.rpm
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/$crpm
wget https://download.docker.com/linux/centos/docker-ce.repo

for F in `rpm2cpio $crpm | cpio -t | grep yum.repos.d 2>&1`; do 
     echo F=$F; 
     rpm2cpio  $crpm | cpio -idv $F; 
done
/bin/cp etc/yum.repos.d/* /etc/yum.repos.d/
for F in `rpm2cpio $crpm | cpio -t | grep RPM-GPG-KEY 2>&1`; do 
     echo F=$F; 
     rpm2cpio  $crpm | cpio -idv $F; 
done
/bin/cp etc/pki/rpm-gpg/* /etc/pki/rpm-gpg
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum clean all
yum makecache fast
yum repolist
