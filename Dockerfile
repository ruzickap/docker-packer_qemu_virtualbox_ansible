FROM ubuntu:latest
LABEL MAINTAINER="Petr Ruzicka <petr.ruzicka@gmail.com>"

# VNC access to the virtual machine (https://www.packer.io/docs/builders/qemu.html#vnc_port_min)
EXPOSE 5999
# SSH port on the host machine which is forwarded to the SSH port on the guest machine (https://www.packer.io/docs/builders/qemu.html#ssh_host_port_min)
EXPOSE 2299

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl git jq libc-dev libvirt-dev pkg-config python3-boto3 python3-cffi-backend python3-jinja2 python3-paramiko python3-pip python3-pyasn1 python3-setuptools python3-wheel python3-winrm python3-yaml qemu-kvm qemu-utils unzip virtualbox \
    && pip3 install ansible \
    && PACKER_LATEST_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r -M '.current_version') \
    && curl https://releases.hashicorp.com/packer/${PACKER_LATEST_VERSION}/packer_${PACKER_LATEST_VERSION}_linux_amd64.zip --output /tmp/packer_linux_amd64.zip \
    && unzip /tmp/packer_linux_amd64.zip -d /usr/local/bin/ \
    && rm -f /tmp/packer_linux_amd64.zip \
    && apt purge -y curl git libc-dev libvirt-dev pkg-config python3-distutils python3-pip python3-setuptools unzip \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

WORKDIR /var/tmp/packer-templates/

ENTRYPOINT ["/usr/local/bin/packer"]
