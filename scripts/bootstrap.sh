#! /bin/bash
set -x

IBMCLOUD_CLI=2.0.3

export DEBIAN_FRONTEND=noninteractive

setup_packages() {
    apt update
    apt install -y \
        sudo \
        curl \
        vim \
        git \
        byobu \
        psmisc \
        python3-pip \

    # cleanup
    rm -r /var/lib/apt/lists /var/cache/apt/archives
}

setup_ibmcloud() {
    cd /tmp
    curl -fL https://download.clis.cloud.ibm.com/ibm-cloud-cli/${IBMCLOUD_CLI}/binaries/IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz -o IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz 
    tar -zxf IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz
    mv /tmp/IBM_Cloud_CLI/ibmcloud /usr/local/bin
    ibmcloud plugin install kubernetes-service
    ibmcloud plugin install container-registry
}

setup_user() {
    apt install sudo

    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

    username=fermo
    password=fermo

    groupadd docker
    adduser --gecos "" --disabled-password $username
    chpasswd <<<"$username:$password"

    addgroup $username sudo
    addgroup $username docker
}


############

setup_packages
setup_user
setup_ibmcloud

