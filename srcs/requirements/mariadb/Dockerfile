FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client && \
    rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]