FROM eeacms/jenkins-slave:3.22

ENV DOCKER_VERSION=17.12.1 \
    DOCKER_COMPOSE_VERSION=1.25.4 \
    DOCKER_COMPOSE_MD5=28c8173eb3d1c3d5005c28dabfb7cb4e \
    CLAIR_SCANNER_VERSION=v12 \
    RANCHER_CLI_VERSION=v0.6.14

RUN apt-get update \
 && apt-get install -y --no-install-recommends apt-transport-https ca-certificates software-properties-common acl \
 && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce=$DOCKER_VERSION* \
 && rm -rf /var/lib/apt/lists/* \
 && curl -o /bin/docker-compose -SL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-Linux-x86_64 \
 && echo "$DOCKER_COMPOSE_MD5  /bin/docker-compose" | md5sum -c - \
 && chmod +x /bin/docker-compose \
 && pip install j2cli \
 && curl -L -o /usr/bin/clair-scanner https://github.com/arminc/clair-scanner/releases/download/$CLAIR_SCANNER_VERSION/clair-scanner_linux_amd64 \
 && chmod 777 /usr/bin/clair-scanner \
 && curl -L -o rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz https://releases.rancher.com/cli/${RANCHER_CLI_VERSION}/rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz \
 && tar -xzvf rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz  \
 && mv rancher-${RANCHER_CLI_VERSION}/rancher /usr/bin/rancher \
 && rm -rf rancher-*

COPY ini/settings.xml.j2 /tmp/settings.xml.j2
COPY scripts/scan_catalog_entry.sh docker-entrypoint-dind.sh /

ENTRYPOINT ["/docker-entrypoint-dind.sh"]
CMD ["java", "-jar", "/bin/swarm-client.jar"]
