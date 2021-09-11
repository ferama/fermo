FROM ubuntu:latest

ENV DIND_TAG=20.10.8-dind
ENV IBMCLOUD_CLI=2.0.3

RUN set -eux \
	apt-get update \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		iptables \
		openssl \
		pigz \
		xz-utils \
        vim \
        curl

ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client

COPY --from=docker:${DIND_TAG} /usr/local/bin/ /usr/local/bin/

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

VOLUME /var/lib/docker

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []