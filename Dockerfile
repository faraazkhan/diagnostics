FROM alpine:3.5
MAINTAINER Faraaz Khan <faraaz@rationalizeit.us>

ENV HELM_LATEST_VERSION="v2.6.0"
ENV KUBECTL_LATEST_VERSION="v1.7.4"

WORKDIR /usr/src/diagnostics

RUN apk --update add bash openssh vim git wget ca-certificates nmap nmap-scripts curl tcpdump net-tools bind-tools jq nmap-ncat \
  && wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
  && tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin \
  && wget -q http://storage.googleapis.com/kubernetes-release/release/${KUBECTL_LATEST_VERSION}/bin/linux/amd64/kubectl \
  && mv kubectl /usr/local/bin \
  && chmod +x /usr/local/bin/kubectl \
  && rm -f /helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
  && rm /var/cache/apk/* \
  && rm -rf /usr/src/diagnostics/*
