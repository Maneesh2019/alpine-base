FROM alpine:edge
MAINTAINER onni@keksi.io

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
    && chmod a+x validate_sha256sum \
    # This is pretty silly but I feel good about myself after putting it in here :)
    && validate_sha256sum validate_sha256sum 0f7b790036f7cd00610cbe9e79c5b6b42d5b0e02beaff9549bdc43fc99910709 \

    # apk helper
    && wget -q -O apk-install https://raw.githubusercontent.com/gliderlabs/docker-alpine/master/builder/scripts/apk-install \
    && validate_sha256sum apk-install f5f10018cba8440e4317b5559665693e5ecf922592b50d20a1c65a8c2f5fd5ab \

    # Nice owner helper
    && wget -q -O owner https://raw.githubusercontent.com/colstrom/owner/master/bin/owner \
    && validate_sha256sum owner e2c69e2742caa88bc1afb8e4575a312f21a9021461d0b5961f9204dc2f630520 \

    # Give execution rights to all scripts in this folder
    && chmod a+x * \

    # Cleanup
    && apk del openssl \
    && rm -rf /var/cache/apk/*
