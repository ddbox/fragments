#!/bin/bash
cd `dirname $0`
source ./setup.sh
echo condor errors for $fact_fqdn
timeout 10 ssh root@$fact_fqdn 'find /var/log/condor -type f | xargs grep -iE "failed|error|exception" | grep -v D_ERROR | grep -v "RequestsFailed\ =\ 0"' 
