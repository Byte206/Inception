# Developer Documentation

## Prerequisites

- Docker >= 24
- Docker Compose >= 2
- make
- A Linux machine or VM (required by the 42 subject)

## Setup from scratch

**1. Clone the repo**

```bash
git clone https://github.com/yourlogin/inception.git
cd inception
```

**2. Add the domain to `/etc/hosts`**

```bash
echo "127.0.0.1   yourlogin.42.fr" | sudo tee -a /etc/hosts
```

**3. Create the `.env` file**

Copy the example and fill in your values or use the makefile script to make a new one:

```bash
cp .env.example .env
```

Required variables:

```
- DOMAIN_NAME: your local domain, used by NGINX and WordPress to build the site URL.
- DB_NAME: the name of the MariaDB database that WordPress will use.
- DB_USER: the database user that WordPress uses to connect to MariaDB.
- DB_PASSWORD: the password for `DB_USER`.
- DB_HOST: the hostname of the database container, usually `mariadb`.
- MYSQL_ROOT_PASSWORD: the MariaDB root password used when the database container is initialized.
- WP_ADMIN_USER: the username for the WordPress administrator account.
- WP_ADMIN_PASSWORD: the password for the WordPress administrator account.
- WP_ADMIN_EMAIL: the email address for the WordPress administrator account.
- WP_USER`: the username for the extra WordPress user created by the entrypoint script.
- WP_USER_PASSWORD: the password for that extra WordPress user.
- WP_USER_EMAIL: the email address for that extra WordPress user
```



## Build and launch

```bash
make        # builds images and starts the stack
make build  # build only, don't start
make up     # start without rebuilding
```

## Useful commands

```bash
make ps       # list containers and their status
make logs     # follow logs from all containers
make stop     # pause containers (keeps data)
make down     # stop and remove containers (keeps data)
make clean    # down + remove orphan containers
make fclean   # remove everything: containers, images, volumes
make re       # fclean + up (full rebuild from zero)
```

To enter a running container:

```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

To check the MariaDB database directly:

```bash
docker exec -it mariadb mariadb -u root -p
```

## Where data is stored

Data is persisted through two named Docker volumes:

| Volume | What it stores | Host path |
|--------|---------------|-----------|
| `wordpress_data` | WordPress files (themes, uploads, plugins) | `~/data/wordpress` |
| `mariadb_data` | MariaDB database files | `~/data/mariadb` |


Data survives `make down` and `make stop`. Only `make fclean` wipes the volumes.

## Project structure

```
inception/
├── Makefile
├── .env
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── conf/wp-setup.sh
        └── mariadb/
            ├── Dockerfile
            └── conf/init.sql
```