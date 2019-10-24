
crpm=centos-release-7-7.1908.0.el7.centos.x86_64.rpm
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/$crpm


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
yum clean all
yum repolist
