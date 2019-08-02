#!/bin/sh -x
if docker ps | grep -q jobsub-server; then
docker kill jobsub-server
fi
if docker ps -a | grep -q jobsub-server; then
docker rm jobsub-server
fi
docker run -d  -p 80:80 -p 9615:9615 -p 9618:9618 -p 443:443 -p 8443:8443  --tmpfs /run  --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro --hostname $(hostname) --name jobsub-server  dbox/jobsub-server
