FROM docker:18.09.7@sha256:310156c95007d6cca1417d0692786fe4da816b886a08bc7de97edf02cab4db31
MAINTAINER Faraaz Khan <faraaz@rationalizeit.us>

ENV HELM_LATEST_VERSION="v2.14.0" \
    KUBECTL_LATEST_VERSION="v1.15.0" \
    ETCD_VERSION=3.3.13 \
    ETCDCTL_API=3 \
    RABBIT_VERSION=3_6_12 \
    SHELL=/bin/bash \
    CTOP_VERSION=0.7.2 \
    CALICOCTL_VERSION="v3.5.7" \
    CLOUD_SDK_VERSION=251.0.0 \
    TERM=xterm \
    PATH=${PATH}:/usr/src/diagnostics/google-cloud-sdk/bin:/usr/src/diagnostics/bin

WORKDIR /usr/src/diagnostics

ADD https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/rabbitmq_v${RABBIT_VERSION}/bin/rabbitmqadmin /usr/local/bin/rabbitmqadmin

COPY . .
RUN set -ex \
    && echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk --no-cache add \
      apache2-utils \
      bash \
      bind-tools \
      bird \
      bridge-utils \
      busybox-extras \
      ca-certificates \
      conntrack-tools \
      curl \
      dhcping \
      drill \
      ethtool \
      file\
      git \
      gnupg \
      groff \
      jq \
      fping \
      iftop \
      iperf3 \
      iproute2 \
      iptables \
      iptraf-ng \
      iputils \
      ipvsadm \
      less \
      libc6-compat \
      liboping \
      mailcap \
      mysql-client \
      mtr \
      net-snmp-tools \
      netcat-openbsd \
      net-tools \
      nftables \
      ngrep \
      nmap \
      nmap-ncat \
      nmap-nping \
      nmap-scripts \
      openssh \
      openssl \
      postgresql-client \
      py-crypto \
      py-crcmod \
      py2-virtualenv \
      python2 \
      redis \
      scapy \
      socat \
      strace \
      tcpdump \
      tcptraceroute \
      util-linux \
      vim \
      wget \
    && apk --update --no-cache -t deps add g++ linux-headers libc6-compat musl py-setuptools python2-dev build-base make \
    && if [[ ! -e /usr/bin/python ]];        then ln -sf /usr/bin/python2.7 /usr/bin/python; fi \
    && if [[ ! -e /usr/bin/python-config ]]; then ln -sf /usr/bin/python2.7-config /usr/bin/python-config; fi \
    && if [[ ! -e /usr/bin/easy_install ]];  then ln -sf /usr/bin/easy_install-2.7 /usr/bin/easy_install; fi \
    && easy_install pip \
    && pip install --upgrade pip \
    && if [[ ! -e /usr/bin/pip ]]; then ln -sf /usr/bin/pip2.7 /usr/bin/pip; fi \
    && pip install --upgrade numpy awscli s3cmd python-magic boto3 \
    && cd /tmp \
    && wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
    && wget -q http://storage.googleapis.com/kubernetes-release/release/${KUBECTL_LATEST_VERSION}/bin/linux/amd64/kubectl \
    && wget -q https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
    && wget -q https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-amd64 -O /usr/local/bin/ctop \
    && wget -q https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VERSION}/calicoctl && chmod +x calicoctl && mv calicoctl /usr/local/bin \
    && wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
    && mv kubectl /usr/local/bin \
    && tar zxvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
    && cp etcd-v${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin/etcdctl \
    && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && mv google-cloud-sdk /usr/src/diagnostics/ \
    && chmod +x -R /usr/src/diagnostics/bin \
    && chmod +x -R /usr/local/bin \
    && apk del deps \
    && mv /usr/sbin/tcpdump /usr/bin/tcpdump \
    && rm -rf /tmp/* /var/cache/distfiles/* /var/cache/apk/*

EXPOSE 5201
CMD exec /bin/sh -c "trap : TERM INT; (while true; do sleep 1000; done) & wait"
