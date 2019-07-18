#!/bin/bash
if [ "$builder" = "" ];then
    builder=$(whoami)
fi
cd `dirname $0`
docker build . --tag "${builder}"/jobsub-server
