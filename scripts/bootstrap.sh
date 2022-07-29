#! /bin/bash
set -x

USERNAME=fermo
PASSWORD=fermo

export DEBIAN_FRONTEND=noninteractive

setup_packages() {
    apt update
    apt install -y \
        sudo \
        vim \
        git \
        byobu \
        psmisc \
        openconnect \
        iputils-ping \
        netcat \
        dnsutils \
        bash-completion

    # cleanup
    rm -r /var/lib/apt/lists /var/cache/apt/archives
}

setup_k8sutils() {
    cd /tmp

    # kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl && sudo mv kubectl /usr/local/bin

    # helm
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
}

setup_user() {
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc
    echo "export PATH=\$PATH" >> /etc/skel/.bashrc
    echo "source <(kubectl completion bash)" >> /etc/skel/.bashrc

    adduser --gecos "" --disabled-password $USERNAME
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    chpasswd <<<"$USERNAME:$PASSWORD"

    groupadd docker
    addgroup $USERNAME sudo
    addgroup $USERNAME docker
}


############
setup_packages
setup_user
setup_k8sutils

