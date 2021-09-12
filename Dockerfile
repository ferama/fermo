FROM ubuntu:latest

# add docker dind
COPY --from=docker:20.10.8-dind /usr/local/bin/ /usr/local/bin/
# add rospo dev version
COPY --from=ferama/rospo:dev /usr/local/bin/rospo /usr/local/bin/rospo

# image extra binaries and utils
COPY bin/* /usr/local/bin

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
        iptables \
		openssl; \
    rm -r /var/lib/apt/lists /var/cache/apt/archives


ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client

VOLUME /var/lib/docker

COPY ./scripts/* /
RUN /bootstrap.sh && rm /bootstrap.sh

ENTRYPOINT ["/entrypoint.sh"]