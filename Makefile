.DEFAULT_GOAL := help

ENV_FILE ?= .env
COMPOSE := docker compose --env-file $(ENV_FILE)
POSTGRES_COMPOSE := postgres/16/docker-compose.yml
REDIS_COMPOSE := redis/docker-compose.yml
LOCALSTACK_COMPOSE := localstack/docker-compose.yml
MAILPIT_COMPOSE := mailpit/docker-compose.yml

.PHONY:
help:
	@printf '%s\n' \
		'make postgres   Start PostgreSQL' \
		'make redis      Start Redis' \
		'make localstack Start LocalStack' \
		'make mailpit    Start Mailpit' \
		'make up         Start all services' \
		'make down       Stop all services'

.PHONY:
network:
	@docker network inspect yepsua-network >/dev/null 2>&1 || docker network create --driver bridge --subnet 10.254.254.0/24 yepsua-network

.PHONY:
postgres-volume:
	@docker volume inspect yepsua-pg16-db >/dev/null 2>&1 || docker volume create yepsua-pg16-db

.PHONY:
postgres: network postgres-volume
	$(COMPOSE) -f $(POSTGRES_COMPOSE) up -d

.PHONY:
redis: network
	$(COMPOSE) -f $(REDIS_COMPOSE) up -d

.PHONY:
localstack: network
	$(COMPOSE) -f $(LOCALSTACK_COMPOSE) up -d

.PHONY:
mailpit: network
	$(COMPOSE) -f $(MAILPIT_COMPOSE) up -d

.PHONY:
up: postgres redis localstack mailpit

.PHONY:
stop:
	$(COMPOSE) -f $(MAILPIT_COMPOSE) stop
	$(COMPOSE) -f $(LOCALSTACK_COMPOSE) stop
	$(COMPOSE) -f $(REDIS_COMPOSE) stop
	$(COMPOSE) -f $(POSTGRES_COMPOSE) stop

.PHONY:
restart: stop up

.PHONY:
down:
	$(COMPOSE) -f $(MAILPIT_COMPOSE) down
	$(COMPOSE) -f $(LOCALSTACK_COMPOSE) down
	$(COMPOSE) -f $(REDIS_COMPOSE) down
	$(COMPOSE) -f $(POSTGRES_COMPOSE) down