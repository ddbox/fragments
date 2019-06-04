#!/bin/bash
cd `dirname $0`
source ./setup.sh
VER=$(./factory.condor_version.sh | perl -ne '@a=split(); print "$a[1]\n"')
if [  "$VER" \< "8.5" ]; then
    NOB=""
else
    NOB="-nobatch -all"
fi
ssh -t root@$fact_fqdn condor_q -g $NOB $1 
