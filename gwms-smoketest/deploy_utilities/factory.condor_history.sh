#!/bin/bash
cd `dirname $0`
source ./setup.sh

timeout 10 ssh root@$fact_fqdn find /var/lib/condor -name history 2>&1 | grep history > /dev/null
has_completed=$?
for H in $(timeout 10 ssh root@$fact_fqdn find /var/lib/condor -name history); do timeout 10 ssh root@$fact_fqdn condor_history -file $H ; done
exit $has_completed
