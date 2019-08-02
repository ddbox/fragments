#!/bin/bash
if [ "$builder" = "" ];then
    builder=$(whoami)
fi
cd `dirname $0`
docker build . $1  --tag "${builder}"/jobsub-server
