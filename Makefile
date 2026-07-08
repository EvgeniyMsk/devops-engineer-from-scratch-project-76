ANSIBLE_DIR := ansible
ANSIBLE_PLAYBOOK := playbook.yml
VAULT_FILE := group_vars/webservers/vault.yml
VAULT_PASSWORD_FILE := $(ANSIBLE_DIR)/vault-password

ifneq ($(wildcard $(VAULT_PASSWORD_FILE)),)
VAULT_ARGS := --vault-password-file $(VAULT_PASSWORD_FILE)
endif

.PHONY: check-vault
check-vault:
	@test -f $(VAULT_PASSWORD_FILE) || ( \
		echo "Ошибка: не найден $(VAULT_PASSWORD_FILE)"; \
		echo "Создайте файл с паролем Ansible Vault из задания Hexlet:"; \
		echo "  echo 'ваш_пароль' > $(VAULT_PASSWORD_FILE) && chmod 600 $(VAULT_PASSWORD_FILE)"; \
		exit 1 \
	)

help: ## Показать список команд
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

galaxy: ## Установка ролей из requirements.yml
	ansible-galaxy install -r requirements.yml -p $(ANSIBLE_DIR)/roles

lint: galaxy ## Проверка playbook с ansible-lint
	cd $(ANSIBLE_DIR) && ansible-lint ../$(ANSIBLE_PLAYBOOK)

ping: check-vault ## Проверка подключения к серверам
	cd $(ANSIBLE_DIR) && ansible all -m ping $(VAULT_ARGS)

install: galaxy check-vault ## Установка Docker и pip на сервера
	cd $(ANSIBLE_DIR) && ansible-playbook ../$(ANSIBLE_PLAYBOOK) --skip-tags redmine,datadog $(VAULT_ARGS)

deploy: galaxy check-vault ## Деплой приложения Redmine
	cd $(ANSIBLE_DIR) && ansible-playbook ../$(ANSIBLE_PLAYBOOK) --tags redmine $(VAULT_ARGS)

datadog: galaxy check-vault ## Установка и настройка агента Datadog
	cd $(ANSIBLE_DIR) && ansible-playbook ../$(ANSIBLE_PLAYBOOK) --tags datadog $(VAULT_ARGS)

vault-edit: ## Редактирование зашифрованных секретов
	ansible-vault edit $(VAULT_FILE) $(VAULT_ARGS)

vault-encrypt: ## Шифрование файла с секретами
	ansible-vault encrypt $(VAULT_FILE) $(VAULT_ARGS)

vault-view: ## Просмотр зашифрованных секретов
	ansible-vault view $(VAULT_FILE) $(VAULT_ARGS)
