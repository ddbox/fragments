FROM opensciencegrid/osg-wn
STOPSIGNAL SIGRTMIN+3
EXPOSE 25 
EXPOSE 80
EXPOSE 443
EXPOSE 9615
EXPOSE 9618
COPY repos/* /etc/yum.repos.d/
ADD systemd /systemd
RUN yum install -y initscripts rsyslog && groupadd fife && \
    useradd condor && useradd grid && useradd rexbatch && useradd dbox && yum -y  install jobsub && \
    systemctl enable condor && systemctl enable httpd &&  systemctl enable rsyslog
ENTRYPOINT [ "/systemd" ]
