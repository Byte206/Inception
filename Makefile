.DEFAULT_GOAL := help

NAME         := inception
DOMAIN_NAME  := $(shell awk -F= '/^DOMAIN_NAME=/{print $$2; exit}' srcs/.env)
COMPOSE_FILE := srcs/docker-compose.yml
DOCKER_PATH  := $(shell if command -v docker.exe >/dev/null 2>&1; then command -v docker.exe; elif command -v docker >/dev/null 2>&1; then command -v docker; fi)
DOCKER       := "$(DOCKER_PATH)"
COMPOSE      := $(shell if command -v docker-compose >/dev/null 2>&1; then command -v docker-compose; else printf '%s' "$(DOCKER) compose"; fi) -f $(COMPOSE_FILE)

.PHONY: all up down start stop build ps logs clean fclean re help check-compose check-docker check-domain

all: up

up: check-docker check-compose check-domain
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

re: fclean up

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

check-compose:
	@test -f $(COMPOSE_FILE) || { printf "Error: missing %s\n" $(COMPOSE_FILE); exit 1; }

check-domain:
	@test -n "$(DOMAIN_NAME)" || { printf "Error: DOMAIN_NAME is missing from srcs/.env\n"; exit 1; }
	@getent hosts $(DOMAIN_NAME) >/dev/null 2>&1 || { \
		printf "Error: %s does not resolve on this machine. Add '127.0.0.1 %s' to /etc/hosts, then reopen the browser.\n" $(DOMAIN_NAME) $(DOMAIN_NAME); \
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