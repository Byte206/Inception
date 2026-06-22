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

Copy the example and fill in your values:

```bash
cp .env.example .env
```

Required variables:

```
DOMAIN_NAME=yourlogin.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@example.com
WP_TITLE=My Site
DATA_PATH=~/data
```

**4. Create the secrets files**

```bash
mkdir -p secrets
echo "your_db_password"       > secrets/db_password.txt
echo "your_db_root_password"  > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_password.txt
```

These files are read by Docker at runtime and mounted inside the containers. Never commit them.

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

The host path is controlled by `DATA_PATH` in your `.env` file.

Data survives `make down` and `make stop`. Only `make fclean` wipes the volumes.

## Project structure

```
inception/
├── Makefile
├── .env
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── wp_admin_password.txt
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