#!/bin/bash
cd `dirname $0`
source ./setup.sh
out=$(timeout 10 ssh root@$fact_fqdn "yum list | grep '@'" )
while IFS= read ; do
   echo $REPLY
done <<< "$out"
