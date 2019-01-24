puppet module list | grep gwms-factory
if [ $? -eq 0 ]; then
    puppet module uninstall gwms-factory
fi
puppet module install gwms-factory-0.0.1.tar.gz
puppet apply -e "class { factory : fact_fqdn => 'fermicloud400.fnal.gov', vofe_fqdn => 'fermicloud346.fnal.gov' }"

