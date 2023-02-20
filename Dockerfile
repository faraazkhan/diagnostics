FROM docker:cli
MAINTAINER Faraaz Khan <faraaz@rationalizeit.us>

ENV HELM_LATEST_VERSION="v3.11.1" \
    KUBECTL_LATEST_VERSION="v1.26.1" \
    ETCD_VERSION=3.4.24 \
    ETCDCTL_API=3 \
    RABBIT_VERSION=3.11.9 \
    SHELL=/bin/bash \
    CTOP_VERSION=0.7.7 \
    CALICOCTL_VERSION="v3.20.6" \
    TERMSHARK_VERSION=2.4.0 \
    GRPC_CURL_VERSION=1.8.7 \
    TERM=xterm \
    PATH=${PATH}:/usr/src/diagnostics/bin

WORKDIR /usr/src/diagnostics

ADD "https://github.com/rabbitmq/rabbitmq-server/releases/download/v$RABBIT_VERSION/rabbitmq-server-generic-unix-latest-toolchain-$RABBIT_VERSION.tar.xz" /tmp/rabbitmq.tar.xz

COPY . .
RUN set -ex \
    && echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
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
      fping \
      git \
      gnupg \
      groff \
      httpie \
      iftop \
      iperf \
      iperf3 \
      iproute2 \
      ipset \
      iptables \
      iptraf-ng \
      iputils \
      ipvsadm \
      jq \
      less \
      libc6-compat \
      liboping \
      ltrace \
      mailcap \
      mtr \
      mysql-client \
      net-snmp-tools \
      net-tools \
      netcat-openbsd \
      nftables \
      ngrep \
      nmap \
      nmap-ncat \
      nmap-nping \
      nmap-scripts \
      openssh \
      openssl \
      perl-crypt-ssleay \
      perl-net-ssleay \
      postgresql-client \
      py3-pip \
      py3-setuptools \
      python3 \
      python3-dev \
      redis \
      scapy \
      socat \
      speedtest-cli \
      strace \
      swaks \
      tcpdump \
      tcptraceroute \
      tshark \
      util-linux \
      vim \
      websocat \
      wget \
      zsh \
    && apk --update --no-cache -t deps add tar xz g++ linux-headers libc6-compat musl build-base make \
    && pip3 install --upgrade pip \
    && pip3 install --upgrade awscli s3cmd python-magic boto3 \
    && cd /tmp \
    && wget -q https://get.helm.sh/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
    && wget -q http://storage.googleapis.com/kubernetes-release/release/${KUBECTL_LATEST_VERSION}/bin/linux/amd64/kubectl \
    && wget -q https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
    && wget -q https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-amd64 -O /usr/local/bin/ctop \
    && wget -q https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VERSION}/calicoctl && chmod +x calicoctl && mv calicoctl /usr/local/bin \
    && wget -q https://github.com/gcla/termshark/releases/download/v${TERMSHARK_VERSION}/termshark_${TERMSHARK_VERSION}_linux_arm64.tar.gz \
    && wget -q https://github.com/fullstorydev/grpcurl/releases/download/v${GRPC_CURL_VERSION}/grpcurl_${GRPC_CURL_VERSION}_linux_x86_64.tar.gz \
    && tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
    && mv kubectl /usr/local/bin \
    && tar zxvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
    && cp etcd-v${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin/etcdctl \
    && tar xzf termshark_${TERMSHARK_VERSION}_linux_arm64.tar.gz \
    && mv termshark_${TERMSHARK_VERSION}_linux_arm64/termshark /usr/local/bin/termshark \
    && tar xzf grpcurl_${GRPC_CURL_VERSION}_linux_x86_64.tar.gz \
    && mv grpcurl /usr/local/bin/ \
    && chmod +x -R /usr/local/bin \
    && tar --extract --file /tmp/rabbitmq.tar.xz --strip-components 1 --directory /usr/local/bin/ \
    && apk del deps \
    && rm -rf /tmp/* /var/cache/distfiles/* /var/cache/apk/* /usr/src/diagnostics/* /root/.cache
RUN chmod -R g=u /root && chown root:root /usr/bin/dumpcap


EXPOSE 5201
CMD ["bash"]
