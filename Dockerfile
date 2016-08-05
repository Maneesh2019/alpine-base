FROM alpine:edge
MAINTAINER onni@keksi.io

# Build arguments
ARG S6_OVERLAY_VERSION=v1.18.1.3

# Finland is quite nice place to live.
# Instead of forking this you should move your living address here.
ENV TZ="Europe/Helsinki"

RUN mkdir -p /usr/local/sbin \
    && cd /usr/local/sbin \

    # Add more repositories for our convenience
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/main | tee /etc/apk/repositories \
    && echo @testing http://dl-cdn.alpinelinux.org/alpine/edge/testing | tee -a /etc/apk/repositories \
    && echo @community http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories \

    # Update openssl to fix: wget: can't execute 'ssl_helper': No such file or directory
    && apk add --update openssl \

    # Install sha256sum validator
    && wget -q -O validate_sha256sum https://gist.githubusercontent.com/onnimonni/b49779ebc96216771a6be3de46449fa1/raw/d3ef37ab4a653e1b7655df55dfeadd54e0bacf84/validate_sha256sum \
    && chmod +x validate_sha256sum \
    # This is pretty silly but I feel good about myself after putting it in here :)
    && validate_sha256sum validate_sha256sum 0f7b790036f7cd00610cbe9e79c5b6b42d5b0e02beaff9549bdc43fc99910709 \

    # apk helper from progrium
    && wget -q -O apk-install https://raw.githubusercontent.com/gliderlabs/docker-alpine/master/builder/scripts/apk-install \
    && validate_sha256sum apk-install f5f10018cba8440e4317b5559665693e5ecf922592b50d20a1c65a8c2f5fd5ab \

    # Nice owner helper from colstrom
    && wget -q -O owner https://raw.githubusercontent.com/colstrom/owner/master/bin/owner \
    && validate_sha256sum owner e2c69e2742caa88bc1afb8e4575a312f21a9021461d0b5961f9204dc2f630520 \

    # Give execution rights to all scripts which we downloaded
    && chmod a+x * \

    ##
    # Add S6-overlay to use S6 process manager
    # source: https://github.com/just-containers/s6-overlay/#the-docker-way
    ##
    && wget -q -O- https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar -xvzC / \

    # Add default timezone
    && apk add tzdata \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \

    # Bash is so basic that it should always be included even for debugging
    && apk add bash \

    # Sanity helpers when attaching into container
    && echo "alias ll='ls -lah'" >> /root/.bashrc \

    # Cleanup
    && apk del openssl tzdata \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["/init"]
