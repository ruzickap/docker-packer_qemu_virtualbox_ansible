FROM ubuntu:latest
LABEL MAINTAINER="Petr Ruzicka <petr.ruzicka@gmail.com>"

ENV PACKER_VERSION="1.2.3"
ENV VAGRANT_VERSION="2.1.1"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl git libc-dev libvirt-dev pkg-config python3-boto3 python3-cffi-backend python3-jinja2 python3-paramiko python3-pip python3-pyasn1 python3-setuptools python3-wheel python3-winrm python3-yaml qemu-kvm qemu-utils unzip virtualbox \
    && pip3 install ansible \
    && curl https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb --output /tmp/vagrant_x86_64.deb \
    && apt install -y /tmp/vagrant_x86_64.deb \
    && vagrant plugin install vagrant-libvirt vagrant-winrm \
    && curl https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip --output /tmp/packer_linux_amd64.zip \
    && unzip /tmp/packer_linux_amd64.zip -d /usr/local/bin/ \
    && rm -f /tmp/packer_linux_amd64.zip \
    && apt purge -y curl git libc-dev libvirt-dev pkg-config python3-distutils python3-pip python3-setuptools unzip \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

WORKDIR /var/tmp/packer-templates/

ENTRYPOINT ["/usr/local/bin/packer"]

#docker run --rm -it --privileged --cap-add=ALL -v /lib/modules:/lib/modules:ro -v $PWD:/var/tmp/packer-templates/ -v /home/pruzicka/data2/iso:/var/tmp/packer-templates/packer_cache/ --entrypoint /bin/bash mypacker
#NAME=my_centos-7-x86_64 CENTOS_VERSION=7 CENTOS_TYPE=NetInstall CENTOS_TAG=1804 packer build -var headless=true my_centos-7.json
#NAME=my_windows-10-enterprise-x64-eval WINDOWS_VERSION=10 VIRTIO_WIN_ISO=./packer_cache/virtio-win.iso ISO_CHECKSUM=27e4feb9102f7f2b21ebdb364587902a70842fb550204019d1a14b120918e455 ISO_URL=https://software-download.microsoft.com/download/pr/17134.1.180410-1804.rs4_release_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso packer build -var headless=true -only=qemu my_windows.json
