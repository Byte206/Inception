.DEFAULT_GOAL := help

NAME         := inception
COMPOSE_FILE := srcs/docker-compose.yml
DOCKER_PATH  := $(shell if command -v docker.exe >/dev/null 2>&1; then command -v docker.exe; elif command -v docker >/dev/null 2>&1; then command -v docker; fi)
DOCKER       := "$(DOCKER_PATH)"
COMPOSE      := $(shell if command -v docker-compose >/dev/null 2>&1; then command -v docker-compose; else printf '%s' "$(DOCKER) compose"; fi) -f $(COMPOSE_FILE)

DATA_DIR     := /home/gamorcil/data

.PHONY: all up down start stop build ps logs clean fclean re help init-dirs

all: init-dirs up

up: init-dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

build:
	$(COMPOSE) build

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down --remove-orphans

fclean:
	$(COMPOSE) down --rmi all --volumes --remove-orphans
	sudo rm -rf $(DATA_DIR)
	rm -f srcs/.env

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
	@printf "  fclean  - remove containers, images, volumes, data and .env\n"
	@printf "  re      - fclean and up\n"