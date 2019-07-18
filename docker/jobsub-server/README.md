# 
## docker container running a jobsub server
build: ./build_all.sh
run: docker run -d -p 80:80 -p 9615:9615 -p 9618:9618 -p 443:443  --tmpfs /run  --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name jobsub-server  dbox/jobsub-server





