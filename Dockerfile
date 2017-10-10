FROM alpine:3.5
MAINTAINER Faraaz Khan <faraaz@rationalizeit.us>

ENV HELM_LATEST_VERSION="v2.6.0" \
    KUBECTL_LATEST_VERSION="v1.7.4" \
    STRESS_VERSION=1.0.4 \
    SHELL=/bin/bash

WORKDIR /usr/src/diagnostics

RUN apk --update add bash openssh vim git wget ca-certificates nmap nmap-scripts curl tcpdump net-tools bind-tools jq nmap-ncat \
  python groff less mailcap mysql-client postgresql-client \
  && apk --update -t deps add py-pip g++ make \
  && pip install --upgrade awscli s3cmd python-magic \
  && wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
  && tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin \
  && wget -q http://storage.googleapis.com/kubernetes-release/release/${KUBECTL_LATEST_VERSION}/bin/linux/amd64/kubectl \
  && mv kubectl /usr/local/bin \
  && chmod +x /usr/local/bin/kubectl \
  && wget -q https://people.seas.harvard.edu/~apw/stress/stress-${STRESS_VERSION}.tar.gz \
  && tar -xvf stress-${STRESS_VERSION}.tar.gz \
  && cd stress-${STRESS_VERSION} \
  && ./configure && make && make install \
  && apk del deps \
  && rm -rf /usr/src/diagnostics/* /var/cache/distfiles/* /var/cache/apk/*

ADD https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/rabbitmq_v3_6_12/bin/rabbitmqadmin /usr/local/bin/rabbitmqadmin
