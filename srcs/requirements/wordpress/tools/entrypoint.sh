#!/bin/sh
set -eu

WORDPRESS_DIR=/var/www/html
WORDPRESS_ARCHIVE=/tmp/wordpress.tar.gz

if [ ! -f "${WORDPRESS_DIR}/wp-config.php" ]; then
    mkdir -p "${WORDPRESS_DIR}"

    if [ ! -d /tmp/wordpress ]; then
        curl -fsSL https://wordpress.org/latest.tar.gz -o "${WORDPRESS_ARCHIVE}"
        tar -xzf "${WORDPRESS_ARCHIVE}" -C /tmp
    fi

    cp -R /tmp/wordpress/. "${WORDPRESS_DIR}/"
    rm -rf /tmp/wordpress "${WORDPRESS_ARCHIVE}"

    cp "${WORDPRESS_DIR}/wp-config-sample.php" "${WORDPRESS_DIR}/wp-config.php"

    sed -i "s/database_name_here/${DB_NAME}/g" "${WORDPRESS_DIR}/wp-config.php"
    sed -i "s/username_here/${DB_USER}/g" "${WORDPRESS_DIR}/wp-config.php"
    sed -i "s/password_here/${DB_PASSWORD}/g" "${WORDPRESS_DIR}/wp-config.php"
    sed -i "s/localhost/${DB_HOST}/g" "${WORDPRESS_DIR}/wp-config.php"
fi

chown -R www-data:www-data "${WORDPRESS_DIR}"

exec php-fpm8.2 -F