FROM docker:18.09.7@sha256:310156c95007d6cca1417d0692786fe4da816b886a08bc7de97edf02cab4db31
MAINTAINER Faraaz Khan <faraaz@rationalizeit.us>

ENV HELM_LATEST_VERSION="v2.12.0" \
    KUBECTL_LATEST_VERSION="v1.13.1" \
    STRESS_VERSION=1.0.4 \
    ETCD_VERSION=3.3.10 \
    ETCDCTL_API=3 \
    RABBIT_VERSION=3_6_12 \
    SHELL=/bin/bash \
    CTOP_VERSION=0.7.2 \
    CALICOCTL_VERSION="v3.5.7" \
    CLOUD_SDK_VERSION=251.0.0 \
    TERM=xterm \
    PATH=${PATH}:/usr/src/diagnostics/bin

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
    && tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
    && wget -q http://storage.googleapis.com/kubernetes-release/release/${KUBECTL_LATEST_VERSION}/bin/linux/amd64/kubectl \
    && mv kubectl /usr/local/bin \
    && chmod +x /usr/local/bin/* \
    && wget -q https://people.seas.harvard.edu/~apw/stress/stress-${STRESS_VERSION}.tar.gz \
    && tar -xvf stress-${STRESS_VERSION}.tar.gz \
    && cd stress-${STRESS_VERSION} \
    && ./configure && make && make install \
    && wget -q https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
    && tar zxvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
    && cp etcd-v${ETCD_VERSION}-linux-amd64/etcdctl /usr/bin/etcdctl \
    && rm -rf etcd-v* \
    && chmod +x /usr/bin/etcdctl \
    && chmod +x -R /usr/src/diagnostics/bin \
    && wget https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-amd64 -O /usr/local/bin/ctop && chmod +x /usr/local/bin/ctop \
    && wget https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VERSION}/calicoctl && chmod +x calicoctl && mv calicoctl /usr/local/bin \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && ln -s /lib /lib64 \
    && apk del deps \
    && mv /usr/sbin/tcpdump /usr/bin/tcpdump \
    && rm -rf /tmp/* /var/cache/distfiles/* /var/cache/apk/*

EXPOSE 5201
CMD exec /bin/sh -c "trap : TERM INT; (while true; do sleep 1000; done) & wait"
