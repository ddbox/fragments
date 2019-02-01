ARG rel=7
#FROM scientificlinux/sl:${rel}
FROM opensciencegrid/osg-wn:3.4-el${rel}
ARG rel
ENV rel ${rel} 
ENV container docker 
STOPSIGNAL SIGRTMIN+3
EXPOSE 25
EXPOSE 80
EXPOSE 443
EXPOSE 9615
EXPOSE 9618
#VOLUME /run
#VOLUME /tmp

ADD systemd /systemd
RUN yum install -y epel-release && yum install -y initscripts  && yum install -y rsyslog
RUN useradd condor && yum -y -q install glideinwms-vofrontend && yum -y -q install condor-python 
RUN systemctl enable condor && systemctl enable httpd && systemctl enable gwms-frontend  && systemctl enable rsyslog
ENTRYPOINT [ "/systemd" ]
#
#RUN yum -y -q install javascriptrrd
#RUN yum -y -q install m2crypto
#RUN yum -y -q install openssl
#RUN yum -y -q install findutils
#RUN yum -y -q install which
#RUN yum -y -q install file
#RUN yum -y -q install git
