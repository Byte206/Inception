FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends nginx openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl /run/nginx

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=localhost"

COPY conf/nginx.conf /etc/nginx/sites-enabled/default

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]