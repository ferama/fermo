#! /bin/bash
set -x

IBMCLOUD_CLI=2.0.3
USERNAME=fermo
PASSWORD=fermo

export DEBIAN_FRONTEND=noninteractive

setup_docker() {
    curl -fsSL https://get.docker.com | sh
}

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
        openconnect \
        iputils-ping \
        netcat \
        dnsutils \
        bash-completion

    # cleanup
    rm -r /var/lib/apt/lists /var/cache/apt/archives
    pip install vpn-slice
}

setup_k8sutils() {
    cd /tmp

    # kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl && sudo mv kubectl /usr/local/bin

    # helm
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    
    # ibmcloud
    curl -fL https://download.clis.cloud.ibm.com/ibm-cloud-cli/${IBMCLOUD_CLI}/binaries/IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz -o IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz 
    tar -zxf IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz
    mv /tmp/IBM_Cloud_CLI/ibmcloud /usr/local/bin
    su -c "ibmcloud plugin install kubernetes-service" $USERNAME
    su -c "ibmcloud plugin install container-registry" $USERNAME
    su -c "ibmcloud plugin install cloud-databases" $USERNAME
}

setup_user() {
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc
    echo "source <(kubectl completion bash)" >> /etc/skel/.bashrc

    adduser --gecos "" --disabled-password $USERNAME
    chpasswd <<<"$USERNAME:$PASSWORD"

    groupadd docker
    addgroup $USERNAME sudo
    addgroup $USERNAME docker
}


############
setup_packages
setup_docker
setup_user
setup_k8sutils

