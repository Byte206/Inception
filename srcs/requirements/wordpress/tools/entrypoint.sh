#!/bin/sh
# Script de entrada para inicializar WordPress en Docker

# Habilita modo strict: -e: salir si hay errores, -u: error si se usa variable sin definir
set -eu

# Define las rutas principales para WordPress
WORDPRESS_DIR=/var/www/html
WORDPRESS_ARCHIVE=/tmp/wordpress.tar.gz

# ===== VERIFICACIÓN E INSTALACIÓN DE WORDPRESS =====
# Verifica si WordPress ya está configurado (si existe wp-config.php)
if [ ! -f "${WORDPRESS_DIR}/wp-config.php" ]; then
    # Crea el directorio de WordPress si no existe
    mkdir -p "${WORDPRESS_DIR}"

    # Descarga e instala WordPress si aún no está en el contenedor
    if [ ! -d /tmp/wordpress ]; then
        # Descarga la última versión de WordPress en comprimido
        curl -fsSL https://wordpress.org/latest.tar.gz -o "${WORDPRESS_ARCHIVE}"
        # Extrae el archivo en el directorio temporal
        tar -xzf "${WORDPRESS_ARCHIVE}" -C /tmp
    fi

    # Copia los archivos de WordPress al directorio principal
    cp -R /tmp/wordpress/. "${WORDPRESS_DIR}/"
    # Limpia los archivos temporales para ahorrar espacio
    rm -rf /tmp/wordpress "${WORDPRESS_ARCHIVE}"

    # Copia el archivo de configuración de ejemplo como punto de partida
    cp "${WORDPRESS_DIR}/wp-config-sample.php" "${WORDPRESS_DIR}/wp-config.php"

    # ===== CONFIGURACIÓN DE LA BASE DE DATOS =====
    # Reemplaza los parámetros de conexión con las variables de entorno
    sed -i "s/database_name_here/${DB_NAME}/g" "${WORDPRESS_DIR}/wp-config.php"
    sed -i "s/username_here/${DB_USER}/g" "${WORDPRESS_DIR}/wp-config.php"
    sed -i "s/password_here/${DB_PASSWORD}/g" "${WORDPRESS_DIR}/wp-config.php"
    sed -i "s/localhost/${DB_HOST}/g" "${WORDPRESS_DIR}/wp-config.php"
fi

# ===== ESPERAR A QUE LA BASE DE DATOS ESTÉ LISTA =====
# Intenta conectarse a MariaDB cada segundo hasta que esté disponible
until mariadb -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

# ===== INSTALACIÓN DE WORDPRESS =====
# Verifica si WordPress ya ha sido instalado (si la base de datos está inicializada)
if ! wp core is-installed --path="${WORDPRESS_DIR}" --allow-root >/dev/null 2>&1; then
    # Instala WordPress con la configuración del sitio
    wp core install \
        --path="${WORDPRESS_DIR}" \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # Crea un usuario adicional con rol de suscriptor
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=subscriber \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="${WORDPRESS_DIR}" \
        --allow-root
fi

# ===== CONFIGURACIÓN DE PERMISOS =====
# Asigna los permisos correctos a www-data (usuario del servidor web)
chown -R www-data:www-data "${WORDPRESS_DIR}"

# ===== INICIO DEL SERVIDOR PHP-FPM =====
# Inicia PHP-FPM 8.2 en modo foreground (required para Docker)
# El flag -F mantiene el proceso en primer plano para que Docker no lo cierre
exec php-fpm8.2 -F