#!/bin/sh
# Script de entrada para inicializar WordPress en Docker
set -eu

WORDPRESS_DIR=/var/www/html
WORDPRESS_ARCHIVE=/tmp/wordpress.tar.gz

# Puerto de la base de datos: usa DB_PORT si está definida, si no, 3306 por defecto
DB_PORT=${DB_PORT:-3306}

# ===== VERIFICACIÓN E INSTALACIÓN DE WORDPRESS =====
if [ ! -f "${WORDPRESS_DIR}/wp-config.php" ]; then
    mkdir -p "${WORDPRESS_DIR}"

    if [ ! -d /tmp/wordpress ]; then
        curl -fsSL https://wordpress.org/latest.tar.gz -o "${WORDPRESS_ARCHIVE}"
        tar -xzf "${WORDPRESS_ARCHIVE}" -C /tmp
    fi

    cp -R /tmp/wordpress/. "${WORDPRESS_DIR}/"
    rm -rf /tmp/wordpress "${WORDPRESS_ARCHIVE}"

    cp "${WORDPRESS_DIR}/wp-config-sample.php" "${WORDPRESS_DIR}/wp-config.php"

    # ===== CONFIGURACIÓN DE LA BASE DE DATOS =====
    sed -i "s/database_name_here/${DB_NAME}/g" "${WORDPRESS_DIR}/wp-config.php"
    sed -i "s/username_here/${DB_USER}/g" "${WORDPRESS_DIR}/wp-config.php"
    sed -i "s/password_here/${DB_PASSWORD}/g" "${WORDPRESS_DIR}/wp-config.php"
    # DB_HOST ahora incluye el puerto en formato host:puerto
    sed -i "s/localhost/${DB_HOST}:${DB_PORT}/g" "${WORDPRESS_DIR}/wp-config.php"
fi

# ===== ESPERAR A QUE LA BASE DE DATOS ESTÉ LISTA =====
until mariadb -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

# ===== INSTALACIÓN DE WORDPRESS =====
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

# ===== CONFIGURACIÓN DE PERMISOS =====
chown -R www-data:www-data "${WORDPRESS_DIR}"

# ===== INICIO DEL SERVIDOR PHP-FPM =====
exec php-fpm8.2 -F