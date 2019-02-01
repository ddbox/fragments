# gwms-frontend
## docker container running a glideinwms frontend
build: ./build_all.sh
run: docker run -d -p 80:80  --tmpfs /run  --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name frontend.service gwms-frontend





