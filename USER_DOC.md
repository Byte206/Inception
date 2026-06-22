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

All credentials are stored in two places:

- **`.env`** — contains usernames, database name, and domain config
- **`secrets/`** — contains password files (one password per file)

| What | Where |
|------|-------|
| WP admin username | `.env` → `WP_ADMIN_USER` |
| WP admin password | `secrets/wp_admin_password.txt` |
| DB username | `.env` → `MYSQL_USER` |
| DB password | `secrets/db_password.txt` |
| DB root password | `secrets/db_root_password.txt` |

## Checking that everything is running

```bash
make ps
```

All three containers (`nginx`, `wordpress`, `mariadb`) should show status `Up`.

To see live logs from all services:

```bash
make logs
```