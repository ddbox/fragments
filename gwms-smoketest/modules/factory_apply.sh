puppet module list | grep gwms-factory
if [ $? -eq 0 ]; then
    puppet module uninstall gwms-factory
fi
puppet module install gwms-factory-0.0.1.tar.gz
puppet apply -e "class { factory : fact_fqdn => 'fermicloud308.fnal.gov', vofe_fqdn => 'fermicloud320.fnal.gov', vofe_dn => '/DC=org/DC=incommon/C=US/ST=IL/L=Batavia/O=Fermi Research Alliance/OU=Fermilab/CN=fermicloud320.fnal.gov' }"

