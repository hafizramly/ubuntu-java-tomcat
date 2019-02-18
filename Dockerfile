FROM ubuntu:16.04

MAINTAINER Mohd Hafiz Ramly <mohd_hafiz.ramly@bbraun.com>

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y software-properties-common git

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java8-installer

RUN apt-get install -y tomcat8 libtcnative-1

RUN apt-get autoremove && apt-get autoclean

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

EXPOSE 8080
EXPOSE 8009

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle
ENV CATALINA_HOME=/usr/share/tomcat8
ENV CATALINA_BASE=/var/lib/tomcat8
ENV WEBAPPS=$CATALINA_BASE/webapps
ENV PATH $PATH:$CATALINA_HOME/bin

RUN \
    mkdir -p ${CATALINA_HOME}/common/classes \
    ${CATALINA_HOME}/common/classes \
    ${CATALINA_HOME}/shared/classes \
    ${CATALINA_HOME}/server/classes \
    ${CATALINA_BASE}/temp \
    && chown tomcat8.tomcat8 /var/lib/tomcat8/temp

WORKDIR ${CATALINA_BASE}
RUN chmod 777 logs work && chown -R tomcat8.tomcat8 logs work

WORKDIR ${CATALINA_HOME}
RUN find ./bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' +;

CMD [ "/usr/share/tomcat8/bin/catalina.sh", "run" ]
