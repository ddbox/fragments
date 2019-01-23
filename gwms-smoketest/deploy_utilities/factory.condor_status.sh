#!/bin/bash
cd `dirname $0`
source ./setup.sh
timeout 10 ssh root@$fact_fqdn condor_status -any $1 
