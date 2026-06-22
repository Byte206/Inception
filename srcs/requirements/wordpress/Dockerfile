FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    wget \
    tar \
    mariadb-client && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html /run/php

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's|^;clear_env = no|clear_env = no|' /etc/php/8.2/fpm/pool.d/www.conf

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]