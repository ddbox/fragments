#!/bin/bash
cd `dirname $0`
source ./setup.sh
timeout 10 ssh root@$fact_fqdn 'find /var/log/gwms-factory -type f | xargs grep -iE "exception|error|failed"' 
