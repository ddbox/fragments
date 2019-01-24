puppet module list | grep gwms-vofrontend
if [ $? -eq 0 ]; then
    puppet module uninstall gwms-vofrontend
fi
puppet module install gwms-vofrontend-0.0.1.tar.gz
puppet apply -e "class { vofrontend : fact_fqdn => 'fermicloud400.fnal.gov', vofe_fqdn => 'fermicloud346.fnal.gov', vofe_dn =>'/DC=org/DC=cilogon/C=US/O=Fermi National Accelerator Laboratory/OU=People/CN=Dennis Box/CN=UID:dbox' }"

