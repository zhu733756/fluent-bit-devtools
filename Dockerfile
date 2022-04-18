# https://github.com/fluent/fluent-bit/blob/master/dockerfiles/Dockerfile.centos7
# FROM fluent/fluent-bit:1.8.12 as builder

FROM centos:7
workdir /etc/fluent-bit

COPY fluentbit.repo /etc/yum.repos.d/fluentbit.repo

RUN mkdir -p /etc/fluent-bit/logs/ /etc/fluent-bit/config/

COPY ./conf/fluent-bit.conf /etc/fluent-bit/
COPY ./conf/systemd.lua /etc/fluent-bit/config/systemd.lua

RUN yum install fluent-bit -y

RUN cp  /opt/fluent-bit/bin/fluent-bit /usr/local/bin/ 

RUN chmod +x /usr/local/bin/fluent-bit && fluent-bit -c /etc/fluent-bit/fluent-bit.conf & > /etc/fluent-bit/logs/fluent-bit.log

ENTRYPOINT ["/bin/bash"]