#!/bin/bash
cd `dirname $0`
source ./setup.sh
timeout 10 ssh root@$vofe_fqdn 'find /var/log/condor -type f | xargs grep -iE "failed|error|exception"' 
