FROM ubuntu:16.04

MAINTAINER Mohd Hafiz Ramly <mohd_hafiz.ramly@bbraun.com>

# Setup your proxy if required
#ENV HTTP_PROXY="http://165.225.112.16:10127"
#ENV HTTPS_POXY="http://165.225.112.16:10127"

# Run package update
RUN apt-get update && apt-get upgrade -y

# Install core apps and Java JDK
RUN apt-get install -y software-properties-common git openjdk-8-jdk

# Install tomcat8
RUN apt-get install -y tomcat8 libtcnative-1

# Cleaning up
RUN apt-get autoremove && apt-get autoclean

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Exposing Tomcat and AJP
EXPOSE 8080
EXPOSE 8009

# Setting up Java and Tomcat environment
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV CATALINA_HOME=/usr/share/tomcat8
ENV CATALINA_BASE=/var/lib/tomcat8
ENV WEBAPPS=$CATALINA_BASE/webapps
ENV PATH=$PATH:$CATALINA_HOME/bin

# Create Tomcat directories
RUN \
    mkdir -p ${CATALINA_HOME}/common/classes \
    ${CATALINA_HOME}/common/classes \
    ${CATALINA_HOME}/shared/classes \
    ${CATALINA_HOME}/server/classes \
    ${CATALINA_BASE}/temp \
    && chown tomcat8.tomcat8 /var/lib/tomcat8/temp

# Changing tomcat ownership and linking
WORKDIR ${CATALINA_BASE}
RUN chmod 777 logs work && chown -R tomcat8.tomcat8 logs work

# Setting up Tomcat8
WORKDIR ${CATALINA_HOME}
RUN find ./bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' +;

# Container run tomcat8
CMD [ "/usr/share/tomcat8/bin/catalina.sh", "run" ]
