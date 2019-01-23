#!/bin/bash
cd `dirname $0`
source ./setup.sh
timeout 10 ssh root@$vofe_fqdn condor_history
