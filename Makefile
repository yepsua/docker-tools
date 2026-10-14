.DEFAULT_GOAL := help

ENV_FILE ?= .env
COMPOSE := docker compose --env-file $(ENV_FILE)
POSTGRES_COMPOSE := postgres/16/docker-compose.yml
REDIS_COMPOSE := redis/docker-compose.yml
LOCALSTACK_COMPOSE := localstack/docker-compose.yml
MAILPIT_COMPOSE := mailpit/docker-compose.yml

.PHONY: help network postgres-volume postgres redis localstack mailpit up down

help:
	@printf '%s\n' \
		'make postgres   Start PostgreSQL' \
		'make redis      Start Redis' \
		'make localstack Start LocalStack' \
		'make mailpit    Start Mailpit' \
		'make up         Start all services' \
		'make down       Stop all services'

network:
	@docker network inspect yepsua-network >/dev/null 2>&1 || docker network create --driver bridge --subnet 10.254.254.0/24 yepsua-network

postgres-volume:
	@docker volume inspect yepsua-pg16-db >/dev/null 2>&1 || docker volume create yepsua-pg16-db

postgres: network postgres-volume
	$(COMPOSE) -f $(POSTGRES_COMPOSE) up -d

redis: network
	$(COMPOSE) -f $(REDIS_COMPOSE) up -d

localstack: network
	$(COMPOSE) -f $(LOCALSTACK_COMPOSE) up -d

mailpit: network
	$(COMPOSE) -f $(MAILPIT_COMPOSE) up -d

up: postgres redis localstack mailpit

down:
	$(COMPOSE) -f $(MAILPIT_COMPOSE) stop
	$(COMPOSE) -f $(LOCALSTACK_COMPOSE) stop
	$(COMPOSE) -f $(REDIS_COMPOSE) stop
	$(COMPOSE) -f $(POSTGRES_COMPOSE) stop