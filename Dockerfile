# use node:8.11 as base image
FROM node:8.11

# install docker, node, gcloud sdk
ENV DOCKER_VERSION 17.12.0~ce-0~debian
RUN apt-get update \
    && apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common \
      jq \
    && curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - \
    && apt-key fingerprint 0EBFCD88 \
    && add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable" \
   && apt-get update \
   && apt-get -y install docker-ce=${DOCKER_VERSION} \
   && rm -rf /var/cache/apt \
   && npm install -g npm \
   && wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz -nv \
   && tar zxf google-cloud-sdk.tar.gz && ./google-cloud-sdk/install.sh --usage-reporting=false --path-update=true \
   && ./google-cloud-sdk/bin/gcloud --quiet components update \
   && ./google-cloud-sdk/bin/gcloud components install docker-credential-gcr
ENV PATH "${PATH}:${PWD}/google-cloud-sdk/bin"

# below files are taken from docker's own image
# see here: https://github.com/docker-library/docker/tree/master/17.12
# see license DOCKER-LICENSE
COPY modprobe.sh /usr/local/bin/modprobe
COPY docker-entrypoint.sh /usr/local/bin/

# the entry point script is needed mainly
# to support use of docker:dind
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "node" ]
