#!/bin/sh
# Script de entrada para inicializar MariaDB en Docker

# Habilita modo strict: -e: salir si hay errores, -u: error si se usa variable sin definir
set -eu

# Define las rutas principales para MariaDB
DATA_DIR=/var/lib/mysql
SOCKET=/run/mysqld/mysqld.sock

# ===== CONFIGURACIÓN DE DIRECTORIOS Y PERMISOS =====
# Crea el directorio de socket de MariaDB
mkdir -p /run/mysqld
# Asigna los permisos correctos al usuario mysql
chown -R mysql:mysql /run/mysqld "$DATA_DIR"

# ===== INICIALIZACIÓN DE LA BASE DE DATOS =====
# Verifica si la base de datos ya ha sido inicializada
if [ ! -d "$DATA_DIR/mysql" ]; then
    # Instala el esquema inicial de MariaDB en el directorio de datos
    mariadb-install-db --user=mysql --datadir="$DATA_DIR" >/dev/null
fi

# ===== INICIO TEMPORAL DE MARIADB PARA CONFIGURACIÓN =====
# Inicia el servidor MariaDB en modo socket (sin acceso de red) para configuración
mariadbd --user=mysql --datadir="$DATA_DIR" --skip-networking --socket="$SOCKET" &
# Guarda el PID del proceso para detenarlo después
pid="$!"

# Espera a que MariaDB esté listo para aceptar conexiones
until mariadb-admin --socket="$SOCKET" ping >/dev/null 2>&1; do
    sleep 1
done

# ===== CONFIGURACIÓN DE LA BASE DE DATOS Y USUARIOS =====
# Crea la base de datos para WordPress (si aún no existe)
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
# Crea el usuario de WordPress con contraseña, permitiendo conexiones desde cualquier host ('%')
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
# Asigna todos los permisos sobre la base de datos de WordPress al usuario creado
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';"
# Configura la contraseña del usuario root de MariaDB
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
# Recarga los permisos para aplicar todos los cambios
mariadb --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

# ===== DETENCIÓN DE LA INSTANCIA TEMPORAL =====
# Detiene el servidor MariaDB temporal de forma segura
mariadb-admin --socket="$SOCKET" -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown
# Espera a que el proceso termine completamente
wait "$pid"


# ===== INICIO DEL SERVIDOR MARIADB FINAL =====
# Inicia MariaDB en modo escucha (bind-address=0.0.0.0) para que otros contenedores puedan conectarse
# El flag 'exec' reemplaza el proceso shell actual con MariaDB
exec mariadbd --user=mysql --datadir="$DATA_DIR" --bind-address=0.0.0.0