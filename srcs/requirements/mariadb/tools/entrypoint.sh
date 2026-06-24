#!/bin/sh
set -eu

DATA_DIR=/var/lib/mysql
SOCKET=/run/mysqld/mysqld.sock

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$DATA_DIR"

if [ ! -d "$DATA_DIR/mysql" ]; then
    mariadb-install-db --user=mysql --datadir="$DATA_DIR" >/dev/null
fi

mariadbd --user=mysql --datadir="$DATA_DIR" --skip-networking --socket="$SOCKET" &
pid="$!"

until mariadb-admin --socket="$SOCKET" ping >/dev/null 2>&1; do
    sleep 1
done

mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';"
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

mariadb-admin --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown
wait "$pid"

exec mariadbd --user=mysql --datadir="$DATA_DIR" --bind-address=0.0.0.0