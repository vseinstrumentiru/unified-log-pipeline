.DEFAULT_GOAL := help
SHELL := /bin/bash
M = $(shell printf "\033[34;1m>>\033[0m")

.PHONY: generate-configs
generate-configs: ## Generate Vector configs
	MSYS_NO_PATHCONV=1 docker run --rm \
		-v "$(PWD)/vector-aggregator/ansible-playbook:/runner/project" \
		quay.io/ansible/ansible-runner:latest \
		ansible-playbook /runner/project/playbook.yml -i "localhost," --connection=local \
		-e 'vector_environment=local-testing' -e 'clickhouse_endpoint=http://clickhouse01:8123'

.PHONY: validate-configs
validate-configs: ## Валидация конфигов Vector
	MSYS_NO_PATHCONV=1 docker run --rm \
		--mount type=bind,source="$(PWD)/vector-aggregator/ansible-playbook/.generated/vector_aggregator_config",target=/etc/vector,readonly \
		timberio/vector:0.45.0-debian \
		validate --config-dir /etc/vector --no-environment

.PHONY: test-configs
test-configs: ## Тестирование конфигов Vector
	MSYS_NO_PATHCONV=1 docker run --rm \
		--mount type=bind,source="$(PWD)/vector-aggregator/ansible-playbook/.generated/vector_aggregator_config",target=/etc/vector,readonly \
		timberio/vector:0.45.0-debian \
		test --config-dir /etc/vector

.PHONY: start
start: ## Запуск всего стека, включает генерацию, валиадцию и тест конфига vector
	docker-compose up -d

.PHONY: force-start
force-start: ## Запуск всего стека с пересозданием ресурсов принудительно
	docker-compose up -d --force-recreate

.PHONY: stop
stop: ## Остановка
	docker-compose down

.PHONY: clean
clean: ## Очистка
	rm -rf vector-aggregator/.generated/*
	docker-compose down -v --remove-orphans

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
