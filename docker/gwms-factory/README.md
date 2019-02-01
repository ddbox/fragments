# gwms-factory
## docker container running a glideinwms factory
build: ./build_all.sh
run: docker run -d -p 80:80  --tmpfs /run  --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name factory.service gwms-factory 





