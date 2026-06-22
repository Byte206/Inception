.DEFAULT_GOAL := help

NAME := inception
COMPOSE_FILE := srcs/docker-compose.yml
COMPOSE := docker compose -f $(COMPOSE_FILE)

.PHONY: all up down start stop build ps logs clean fclean re help check-compose

all: up

up: check-compose
	$(COMPOSE) up -d --build

down: check-compose
	$(COMPOSE) down

start: check-compose
	$(COMPOSE) start

stop: check-compose
	$(COMPOSE) stop

build: check-compose
	$(COMPOSE) build

ps: check-compose
	$(COMPOSE) ps

logs: check-compose
	$(COMPOSE) logs -f

clean: check-compose
	$(COMPOSE) down --remove-orphans

fclean: check-compose
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
