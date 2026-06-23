.DEFAULT_GOAL := help

NAME         := inception
COMPOSE_FILE := srcs/docker-compose.yml
DOCKER_PATH  := $(shell if command -v docker.exe >/dev/null 2>&1; then command -v docker.exe; elif command -v docker >/dev/null 2>&1; then command -v docker; fi)
DOCKER       := "$(DOCKER_PATH)"
COMPOSE      := $(DOCKER) compose -f $(COMPOSE_FILE)

.PHONY: all up down start stop build ps logs clean fclean re help check-compose check-docker

all: up

up: check-docker check-compose
	$(COMPOSE) up -d --build

down: check-docker check-compose
	$(COMPOSE) down

start: check-docker check-compose
	$(COMPOSE) start

stop: check-docker check-compose
	$(COMPOSE) stop

build: check-docker check-compose
	$(COMPOSE) build

ps: check-docker check-compose
	$(COMPOSE) ps

logs: check-docker check-compose
	$(COMPOSE) logs -f

clean: check-docker check-compose
	$(COMPOSE) down --remove-orphans

fclean: check-docker check-compose
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

check-docker:
	@test -n "$(DOCKER_PATH)" || { printf "Error: Docker CLI not found. Enable Docker Desktop WSL integration or install docker.\n"; exit 1; }
	@$(DOCKER) info >/dev/null 2>&1 || { printf "Error: Docker engine is not running or not reachable. Start Docker Desktop and make sure WSL integration is enabled.\n"; exit 1; }