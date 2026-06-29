*This project has been created as part of the 42 curriculum by gamorcil.*

# Inception

## Description

Inception is a 42 project where you set up a small web infrastructure using Docker Compose. Each service runs in its own container built from scratch (no pre-made images): NGINX as the entry point on port 443, WordPress with php-fpm, and MariaDB as the database.

The point of the project is to understand how containers work, how they communicate, and how to manage data and secrets properly.

**Key design decisions:**

- **VMs vs Docker** — VMs virtualize full hardware, each with its own OS. Docker shares the host kernel and isolates at the process level. Much lighter and faster for running isolated services.
- **Secrets vs Env Variables** — Env vars are visible in `docker inspect` and logs. Docker secrets are mounted as files inside the container and never exposed, so they're used for passwords and credentials.
- **Docker Network vs Host Network** — Host network gives containers direct access to the host's interfaces (no isolation). A custom bridge network keeps containers isolated and lets them communicate by name.
- **Volumes vs Bind Mounts** — Bind mounts point to a specific host path. Named volumes are managed by Docker and are more portable. Used for database data and WordPress files.

## Instructions

**1. Add your domain to `/etc/hosts`:(default on this repo is gamorcil)**
```
127.0.0.1   yourlogin.42.fr
```

**2. Create your secrets files:**
```bash
mkdir -p secrets
echo "your_db_password"      > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
echo "your_wp_admin_password"> secrets/wp_admin_password.txt
```

**3. Fill in `.env` with your settings** (login, domain, db name, etc.)

You can create this file manually or let the `Makefile` create it for you the first time you run `make all`. If `srcs/.env` does not exist, `make all` will ask you for each value and generate the file automatically.

The variables used in `.env` are:

- `DOMAIN_NAME`: your local domain, used by NGINX and WordPress to build the site URL.
- `DB_NAME`: the name of the MariaDB database that WordPress will use.
- `DB_USER`: the database user that WordPress uses to connect to MariaDB.
- `DB_PASSWORD`: the password for `DB_USER`.
- `DB_HOST`: the hostname of the database container, usually `mariadb`.
- `MYSQL_ROOT_PASSWORD`: the MariaDB root password used when the database container is initialized.
- `WP_ADMIN_USER`: the username for the WordPress administrator account.
- `WP_ADMIN_PASSWORD`: the password for the WordPress administrator account.
- `WP_ADMIN_EMAIL`: the email address for the WordPress administrator account.
- `WP_USER`: the username for the extra WordPress user created by the entrypoint script.
- `WP_USER_PASSWORD`: the password for that extra WordPress user.
- `WP_USER_EMAIL`: the email address for that extra WordPress user.

**4. Run:**
```bash
make
```

Then go to `https://yourlogin.42.fr`. Accept the self-signed cert warning and you'll see WordPress.

```bash
make down   # stop containers
make clean  # remove everything
make re     # full rebuild
```

## Resources

- [Docker docs](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX docs](https://nginx.org/en/docs/)
- [WP-CLI](https://wp-cli.org/)
- [MariaDB docs](https://mariadb.com/kb/en/documentation/)

**AI usage:** Claude (claude.ai) was used to debug config issues and clarify concepts like FastCGI passthrough, WP-CLI scripting, and Docker volume behavior. It didn't write the code, but it helped understand why things weren't working.