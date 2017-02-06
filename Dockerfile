FROM armhf/alpine:latest
MAINTAINER BrainGamer

ENV DOCKER_GEN_VERSION 0.7.3
ENV NGINX_VERSION 1.10.2

# Install Forego
ADD https://github.com/djmaze/armhf-forego/releases/download/v0.16.1/forego /usr/local/bin/forego

# Get everything ready
RUN apk add --update \
  nginx bash wget ca-certificates && \
  mkdir -p /run/nginx && \
  chmod u+x /usr/local/bin/forego && \
  wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
  tar -C /usr/local/bin -xvzf docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
  rm /docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
  rm -rf /var/lib/nginx/html && \
  apk del wget ca-certificates && \
  rm -rf /var/cache/apk/*
  
# Configure Nginx and apply fix for very long server names
COPY ./nginx.conf /etc/nginx/nginx.conf
#RUN sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
