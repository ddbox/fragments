puppet module list | grep gwms-factory
if [ $? -eq 0 ]; then
    puppet module uninstall gwms-factory
fi
puppet module install gwms-factory-0.0.1.tar.gz
puppet apply -e "class { factory : fact_fqdn => 'fermicloud115.fnal.gov', vofe_fqdn => 'fermicloud368.fnal.gov', vofe_dn => '/DC=org/DC=cilogon/C=US/O=Fermi National Accelerator Laboratory/OU=People/CN=Dennis Box/CN=UID:dbox' }"

