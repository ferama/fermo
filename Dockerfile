FROM ubuntu:latest

# add docker dind
COPY --from=docker:20.10.8-dind /usr/local/bin/ /usr/local/bin/
# add rospo dev version
COPY --from=ferama/rospo:dev /usr/local/bin/rospo /usr/local/bin/rospo

COPY bin/* /usr/local/bin

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
        sudo \
		ca-certificates \
		iptables \
		openssl \
		pigz \
		xz-utils \
        vim \
        curl

ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client

ENV IBMCLOUD_CLI=2.0.3
# add ibmcloud utility
RUN cd /tmp \
    && curl -fL https://download.clis.cloud.ibm.com/ibm-cloud-cli/${IBMCLOUD_CLI}/binaries/IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz -o IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz \
    && tar -zxf IBM_Cloud_CLI_${IBMCLOUD_CLI}_linux_amd64.tgz \
    && mv /tmp/IBM_Cloud_CLI/ibmcloud /usr/local/bin \
    && ibmcloud plugin install kubernetes-service \
    && ibmcloud plugin install container-registry

# add rospo
# RUN curl -L https://github.com/ferama/rospo/releases/latest/download/rospo-linux-amd64 --output rospo && chmod +x rospo
# RUN mv rospo /usr/local/bin


VOLUME /var/lib/docker

COPY ./scripts/bootstrap.sh /bootstrap.sh
RUN /bootstrap.sh

ENTRYPOINT ["dockerd-entrypoint.sh"]