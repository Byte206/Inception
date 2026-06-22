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

until mariadb -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

if ! wp core is-installed --path="${WORDPRESS_DIR}" --allow-root >/dev/null 2>&1; then
    wp core install \
        --path="${WORDPRESS_DIR}" \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=subscriber \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="${WORDPRESS_DIR}" \
        --allow-root
fi

chown -R www-data:www-data "${WORDPRESS_DIR}"

exec php-fpm8.2 -F