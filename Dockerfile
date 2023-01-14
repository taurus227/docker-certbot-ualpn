# Docker Arch (amd64, arm32v6, ...)
ARG TARGET_ARCH
ENV TARGET_ARCH=amd64
FROM ${TARGET_ARCH}/python:3.10-alpine3.16

USER root

EXPOSE 80 443
VOLUME /etc/letsencrypt /var/lib/letsencrypt
WORKDIR /opt/certbot

# based on https://github.com/ndilieto/certbot-ualpn
RUN    mkdir uacme
# download and install ualpn:
    && wget -O - https://github.com/ndilieto/uacme/archive/upstream/latest.tar.gz | tar zx -C uacme --strip-components=1
    && cd uacme
    && ./configure
    && make
    && sudo make install
    && cd ..
# install certbot 1.7.0 or later:
    && git clone https://github.com/certbot/certbot
    && cd certbot
    && python tools/venv3.py
    && source venv3/bin/activate
    && cd ..
# install certbot-ualpn plugin:
    && git clone https://github.com/ndilieto/certbot-ualpn
    && cd certbot-ualpn
    && python setup.py install
    && cd ..

# lauch ualpn in server mode:
CMD ualpn -v -d -u nobody:nogroup -c 192.168.11.20@4444 -S 666
