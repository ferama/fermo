FROM docker:dind

RUN apk update && apk add \
    curl \
    vim \
    bash

ENV IBMCLOUD_CLI=2.0.0
# add ibmcloud utility
RUN cd /tmp \
    && curl -fL https://download.clis.cloud.ibm.com/ibm-cloud-cli/${IBMCLOUD_CLI}/binaries/IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz -o IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz \
    && tar -zxf IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz \
    && mv /tmp/IBM_Cloud_CLI/ibmcloud /usr/local/bin \
    && ibmcloud plugin install kubernetes-service

# add rospo
RUN curl -L https://github.com/ferama/rospo/releases/latest/download/rospo-linux-amd64 --output rospo && chmod +x rospo
RUN mv rospo /usr/local/bin

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]