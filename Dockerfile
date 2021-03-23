FROM docker:20.10
MAINTAINER Faraaz Khan <faraaz@rationalizeit.us>

ENV HELM_LATEST_VERSION="v3.5.3" \
    KUBECTL_LATEST_VERSION="v1.20.5" \
    ETCD_VERSION=3.4.13 \
    ETCDCTL_API=3 \
    RABBIT_VERSION=3.8.14 \
    SHELL=/bin/bash \
    CTOP_VERSION=0.7.5 \
    CALICOCTL_VERSION="v3.18.1" \
    CLOUD_SDK_VERSION=332.0.0 \
    TERM=xterm \
    PATH=${PATH}:/usr/src/diagnostics/google-cloud-sdk/bin:/usr/src/diagnostics/bin

WORKDIR /usr/src/diagnostics

ADD "https://github.com/rabbitmq/rabbitmq-server/releases/download/v$RABBIT_VERSION/rabbitmq-server-generic-unix-latest-toolchain-$RABBIT_VERSION.tar.xz" /tmp/rabbitmq.tar.xz

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
      python3 \
      python3-dev \
      py3-pip \
      redis \
      scapy \
      socat \
      strace \
      tcpdump \
      tcptraceroute \
      util-linux \
      vim \
      wget \
    && apk --update --no-cache -t deps add tar xz g++ linux-headers libc6-compat musl build-base make \
    && pip3 install --upgrade pip \
    && pip3 install --upgrade awscli s3cmd python-magic boto3 \
    && cd /tmp \
    && wget -q https://get.helm.sh/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
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
    && tar --extract --file /tmp/rabbitmq.tar.xz --strip-components 1 --directory /usr/local/bin/ \
    && apk del deps \
    && rm -rf /tmp/* /var/cache/distfiles/* /var/cache/apk/*

EXPOSE 5201
CMD exec /bin/sh -c "trap : TERM INT; (while true; do sleep 1000; done) & wait"
