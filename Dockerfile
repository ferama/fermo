FROM docker:dind

RUN apk update && apk add \
    curl \
    vim \
    bash

ENV IBMCLOUD_CLI=2.0.3
# add ibmcloud utility
RUN cd /tmp \
    && curl -fL https://download.clis.cloud.ibm.com/ibm-cloud-cli/${IBMCLOUD_CLI}/binaries/IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz -o IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz \
    && tar -zxf IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz \
    && mv /tmp/IBM_Cloud_CLI/ibmcloud /usr/local/bin \
    && ibmcloud plugin install kubernetes-service \
    && ibmcloud plugin install container-registry

# add rospo
RUN curl -L https://github.com/ferama/rospo/releases/latest/download/rospo-linux-amd64 --output rospo && chmod +x rospo
RUN mv rospo /usr/local/bin

# hard fixes
RUN \
    sed -i 's/\/bin\/ash/\/bin\/bash/g' /etc/passwd \
    && ln -s /usr/local/bin/docker /usr/bin/docker

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]