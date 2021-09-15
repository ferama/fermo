FROM ubuntu:latest

# add docker dind. I'm not using dind as base image because it is apline
# based and I want / need ubuntu as base
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

COPY ./scripts/bootstrap.sh /
RUN /bootstrap.sh && rm /bootstrap.sh

COPY ./scripts/entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]