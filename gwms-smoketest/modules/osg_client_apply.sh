puppet module list | grep gwms-osg_client
if [ $? -eq 0 ]; then
    puppet module uninstall gwms-osg_client
fi
puppet module install gwms-osg_client-0.0.1.tar.gz
puppet apply -e "class { osg_client :  }"

