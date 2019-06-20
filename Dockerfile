FROM ubuntu:latest
LABEL MAINTAINER="Petr Ruzicka <petr.ruzicka@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN addgroup --gid 1001 docker && \
    adduser --uid 1001 --ingroup docker --home /home/docker --shell /bin/sh --disabled-password --gecos "" docker

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl git jq python3-cffi-backend python3-distutils python3-jinja2 python3-paramiko python3-pip python3-pyasn1 python3-setuptools python3-wheel python3-winrm python3-yaml qemu-kvm qemu-utils unzip virtualbox-ext-pack virtualbox-qt \
    \
    && pip3 install --no-cache-dir ansible \
    \
    && PACKER_LATEST_VERSION="$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r -M '.current_version')" \
    && curl https://releases.hashicorp.com/packer/${PACKER_LATEST_VERSION}/packer_${PACKER_LATEST_VERSION}_linux_amd64.zip --output /tmp/packer_linux_amd64.zip \
    && unzip /tmp/packer_linux_amd64.zip -d /usr/local/bin/ \
    && rm -f /tmp/packer_linux_amd64.zip \
    \
    && FIXUID_VERSION=$(curl --silent "https://api.github.com/repos/boxboat/fixuid/releases/latest" | sed -n 's/.*"tag_name": "v\([^"]*\)",/\1/p') \
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: docker\ngroup: docker\npaths:\n  - /home/docker" > /etc/fixuid/config.yml \
    \
    && apt purge -y curl git jq python3-distutils python3-pip python3-setuptools python3-wheel unzip \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

ADD startup_script.sh /

USER docker:docker

WORKDIR /home/docker/packer

ENTRYPOINT ["/startup_script.sh"]
