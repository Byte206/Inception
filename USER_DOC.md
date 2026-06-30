# User Documentation

## What does this stack do?

This project runs a WordPress website with three services:

- **NGINX** — the web server, accessible on port 443 (HTTPS)
- **WordPress** — the content management system
- **MariaDB** — the database where all WordPress data is stored

## Starting and stopping

```bash
make        # start everything
make stop   # pause the containers (data is kept)
make down   # stop and remove the containers (data is kept)
```

## Accessing the site

Open your browser and go to:

```
https://yourlogin.42.fr
```

You will see a certificate warning because the SSL certificate is self-signed. Click "Accept the risk and continue" (or equivalent in your browser).

**WordPress admin panel:**

```
https://yourlogin.42.fr/wp-admin
```

Log in with the admin credentials defined in your `.env` file.

## Credentials

All credentials are stored in the .env file:

- **`.env`** — contains usernames, database name, and domain config,you can copy or paste your .env or create a new one with makefile

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
- `WP_USER_EMAIL`: the email address for that extra WordPress user

## Checking that everything is running

```bash
make ps
```

All three containers (`nginx`, `wordpress`, `mariadb`) should show status `Up`.

To see live logs from all services:

```bash
make logs
```