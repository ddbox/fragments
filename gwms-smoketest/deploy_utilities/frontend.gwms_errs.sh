#!/bin/bash
cd `dirname $0`
source ./setup.sh
echo gwms errors for $vofe_fqdn
timeout 10 ssh root@$vofe_fqdn 'find /var/log/gwms-frontend -type f | xargs grep -iE "failed|error|exception"' 
