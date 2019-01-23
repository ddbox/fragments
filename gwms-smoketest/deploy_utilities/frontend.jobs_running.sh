#!/bin/bash
cd `dirname $0`
source ./setup.sh

#timeout 10 ssh root@$vofe_fqdn condor_q -g -nob -all  | grep ' R ' > /dev/null 2>&1
./frontend.condor_q.sh | grep ' R ' > /dev/null 2>&1
if [ $? -eq 0 ]; then
    if [ "$1" = "-v" ]; then
        echo user jobs running on $vofe_fqdn
    fi
    exit 0
else
    if [ "$1" = "-v" ]; then
        echo no user jobs running on $vofe_fqdn
    fi
    exit 1
fi
