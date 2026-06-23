ANSIBLE_DIR := ansible
ANSIBLE_PLAYBOOK := playbooks/playbook.yml

help: ## Показать список команд
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

lint: galaxy
	cd $(ANSIBLE_DIR) && ansible-lint $(ANSIBLE_PLAYBOOK)

ping: ## Проверка подключения к серверам
	cd $(ANSIBLE_DIR) && ansible all -m ping

galaxy: ## Установка ролей из requirements.yml
	ansible-galaxy install -r requirements.yml -p $(ANSIBLE_DIR)/roles

install: galaxy ## Установка Docker и pip на сервера
	cd $(ANSIBLE_DIR) && ansible-playbook $(ANSIBLE_PLAYBOOK)
