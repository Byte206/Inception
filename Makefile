.DEFAULT_GOAL := help

NAME         := inception
DOMAIN_NAME  = $(shell if [ -f srcs/.env ]; then awk -F= '/^DOMAIN_NAME=/{print $$2; exit}' srcs/.env; fi)
COMPOSE_FILE := srcs/docker-compose.yml
DOCKER_PATH  := $(shell if command -v docker.exe >/dev/null 2>&1; then command -v docker.exe; elif command -v docker >/dev/null 2>&1; then command -v docker; fi)
DOCKER       := "$(DOCKER_PATH)"
COMPOSE      := $(shell if command -v docker-compose >/dev/null 2>&1; then command -v docker-compose; else printf '%s' "$(DOCKER) compose"; fi) -f $(COMPOSE_FILE)

DATA_DIR     := /home/gamorcil/data

.PHONY: all up down start stop build ps logs clean fclean re help check-compose check-docker check-domain check-env init-dirs

all: check-env init-dirs up

up: check-docker check-compose check-domain init-dirs
	$(COMPOSE) up -d --build

down: check-docker check-compose check-domain
	$(COMPOSE) down

start: check-docker check-compose check-domain
	$(COMPOSE) start

stop: check-docker check-compose check-domain
	$(COMPOSE) stop

build: check-docker check-compose check-domain
	$(COMPOSE) build

ps: check-docker check-compose check-domain
	$(COMPOSE) ps

logs: check-docker check-compose check-domain
	$(COMPOSE) logs -f

clean: check-docker check-compose check-domain
	$(COMPOSE) down --remove-orphans

fclean: check-docker check-compose check-domain
	$(COMPOSE) down --rmi all --volumes --remove-orphans
	sudo rm -rf $(DATA_DIR)

re: fclean up

init-dirs:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

help:
	@printf "Available targets:\n"
	@printf "  all     - build and start the stack\n"
	@printf "  up      - build and start the stack in detached mode\n"
	@printf "  down    - stop and remove containers\n"
	@printf "  start   - start existing containers\n"
	@printf "  stop    - stop running containers\n"
	@printf "  build   - build the images\n"
	@printf "  ps      - show running containers\n"
	@printf "  logs    - follow container logs\n"
	@printf "  clean   - stop containers and remove orphans\n"
	@printf "  fclean  - remove containers, images and volumes\n"
	@printf "  re      - fclean and up\n"

check-env:
	@if [ ! -f srcs/.env ]; then \
		printf "\n🔧 Creating srcs/.env file...\n"; \
		printf "\n📝 Please enter the required configuration values:\n\n"; \
		prompt_default() { \
			prompt="$$1"; \
			default_value="$$2"; \
			printf "%s [%s]: " "$$prompt" "$$default_value" >&2; \
			IFS= read -r input_value; \
			printf "%s" "$${input_value:-$$default_value}"; \
		}; \
		prompt_secret_default() { \
			prompt="$$1"; \
			default_value="$$2"; \
			printf "%s" "$$prompt" >&2; \
			old_stty=$$(stty -g); \
			stty -echo; \
			IFS= read -r secret_value; \
			stty "$$old_stty"; \
			printf "\n" >&2; \
			printf "%s" "$${secret_value:-$$default_value}"; \
		}; \
		domain=$$(prompt_default "DOMAIN_NAME" "gamorcil.42.fr"); \
		db_name=$$(prompt_default "DB_NAME" "wordpress"); \
		db_user=$$(prompt_default "DB_USER" "gamorcil"); \
		db_pass=$$(prompt_secret_default "DB_PASSWORD: " "122"); \
		db_host=$$(prompt_default "DB_HOST" "mariadb"); \
		mysql_root_pass=$$(prompt_secret_default "MYSQL_ROOT_PASSWORD: " "1212"); \
		wp_admin_user=$$(prompt_default "WP_ADMIN_USER" "gamorcil"); \
		wp_admin_pass=$$(prompt_secret_default "WP_ADMIN_PASSWORD: " "1212"); \
		wp_admin_email=$$(prompt_default "WP_ADMIN_EMAIL" "gabimagister@outlook.es"); \
		wp_user=$$(prompt_default "WP_USER" "visitor"); \
		wp_user_pass=$$(prompt_secret_default "WP_USER_PASSWORD: " "1212"); \
		wp_user_email=$$(prompt_default "WP_USER_EMAIL" "gabimagister@outlook.es"); \
		mkdir -p srcs; \
		printf "DOMAIN_NAME=%s\n" "$$domain" > srcs/.env; \
		printf "DB_NAME=%s\n" "$$db_name" >> srcs/.env; \
		printf "DB_USER=%s\n" "$$db_user" >> srcs/.env; \
		printf "DB_PASSWORD=%s\n" "$$db_pass" >> srcs/.env; \
		printf "DB_HOST=%s\n" "$$db_host" >> srcs/.env; \
		printf "MYSQL_ROOT_PASSWORD=%s\n" "$$mysql_root_pass" >> srcs/.env; \
		printf "WP_ADMIN_USER=%s\n" "$$wp_admin_user" >> srcs/.env; \
		printf "WP_ADMIN_PASSWORD=%s\n" "$$wp_admin_pass" >> srcs/.env; \
		printf "WP_ADMIN_EMAIL=%s\n" "$$wp_admin_email" >> srcs/.env; \
		printf "WP_USER=%s\n" "$$wp_user" >> srcs/.env; \
		printf "WP_USER_PASSWORD=%s\n" "$$wp_user_pass" >> srcs/.env; \
		printf "WP_USER_EMAIL=%s\n" "$$wp_user_email" >> srcs/.env; \
		printf "✅ srcs/.env created successfully\n\n"; \
	fi

check-compose:
	@test -f $(COMPOSE_FILE) || { printf "Error: missing %s\n" $(COMPOSE_FILE); exit 1; }

check-domain:
	@domain_name=$$(awk -F= '/^DOMAIN_NAME=/{print $$2; exit}' srcs/.env); \
	test -n "$$domain_name" || { printf "Error: DOMAIN_NAME is missing from srcs/.env\n"; exit 1; }; \
	getent hosts "$$domain_name" >/dev/null 2>&1 || { \
		printf "Error: %s does not resolve on this machine. Add '127.0.0.1 %s' to /etc/hosts, then reopen the browser.\n" "$$domain_name" "$$domain_name"; \
		exit 1; \
	}

check-docker:
	@test -n "$(DOCKER_PATH)" || { printf "Error: Docker CLI not found. Install Docker and ensure the 'docker' command is in PATH.\n"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || $(DOCKER) compose version >/dev/null 2>&1 || { \
		printf "Error: Docker Compose is not available. Install docker-compose or Docker Compose v2.\n"; \
		exit 1; \
	}
	@$(DOCKER) info >/dev/null 2>&1 || { \
		if [ "`uname -s`" = "Linux" ]; then \
			printf "Error: Docker engine is not running or not reachable. Start the Docker service (for example: sudo systemctl start docker) and ensure your user can access /var/run/docker.sock (docker group).\n"; \
		else \
			printf "Error: Docker engine is not running or not reachable. Start Docker Desktop and make sure your integration settings are enabled.\n"; \
		fi; \
		exit 1; \
	}