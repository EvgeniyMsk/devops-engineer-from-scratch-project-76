### Hexlet tests and linter status:
[![Actions Status](https://github.com/EvgeniyMsk/devops-engineer-from-scratch-project-76/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/EvgeniyMsk/devops-engineer-from-scratch-project-76/actions)

## Описание

[Задеплоенное приложение](https://task6.devops-campus.ru)

Проект разворачивает инфраструктуру в Yandex Cloud и настраивает серверы с помощью Ansible:

- 2 виртуальные машины с Ubuntu и Docker
- Application Load Balancer с HTTP/HTTPS
- Managed PostgreSQL (Yandex Cloud)
- Redmine в Docker
- Агент Datadog с HTTP-проверкой приложения

## Структура проекта

```
.
├── playbook.yml                 # Ansible playbook
├── requirements.yml             # Роли и коллекции Galaxy
├── Makefile
├── group_vars/
│   ├── all/vars.yml             # Общие переменные (docker, redmine_port)
│   └── webservers/
│       ├── vars.yml             # Переменные для webservers (БД, Datadog)
│       ├── vault.yml            # Зашифрованные секреты (в git)
│       └── vault.yml.example
├── templates/.env.j2            # Шаблон env-файла Redmine
├── ansible/
│   ├── ansible.cfg
│   ├── inventories/inventory.ini
│   └── vault-password           # Пароль vault (локально, не в git)
└── terraform/
    ├── *.tf
    ├── certs/                   # TLS-сертификаты (локально, не в git)
    ├── terraform.tfvars.example
    └── terraform.tfvars         # Секреты Terraform (локально, не в git)
```

## Требования

- Terraform >= 1.5
- Ansible
- make
- SSH-ключ `~/.ssh/id_rsa` и `~/.ssh/id_rsa.pub`
- Пароль Ansible Vault (файл `ansible/vault-password`, не коммитить)

## Быстрый старт

```bash
make help
```

## Подготовка инфраструктуры (Terraform)

```bash
cd terraform

# TLS-сертификат для домена
mkdir -p certs
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout certs/key.pem -out certs/cert.pem -days 365 \
  -subj "/CN=task6.devops-campus.ru"

# Локальные переменные (не коммитить)
cp terraform.tfvars.example terraform.tfvars
# отредактируйте terraform.tfvars

terraform init
terraform plan
terraform apply
```

После `terraform apply` обновите:

1. `ansible/inventories/inventory.ini` — IP из outputs `vm1_public_ip` и `vm2_public_ip`
2. `group_vars/webservers/vars.yml` — `redmine_db_host` (FQDN Managed PostgreSQL из консоли Yandex Cloud или `terraform output postgresql_host`)

## Секреты (Ansible Vault)

Создайте пароль vault:

```bash
echo 'ваш_пароль_из_задания' > ansible/vault-password
chmod 600 ansible/vault-password
```

Создайте или отредактируйте `group_vars/webservers/vault.yml` (шаблон — `vault.yml.example`):

```yaml
vault_redmine_db_password: "your-db-password"
vault_redmine_secret_key_base: "your-secret-key-base"
vault_datadog_api_key: "your-datadog-api-key"
```

Пароль `vault_redmine_db_password` должен совпадать с паролем пользователя БД в Managed PostgreSQL.

Команды для работы с vault:

```bash
make vault-edit
make vault-encrypt
make vault-view
```

Команды `make install`, `make deploy`, `make ping` и `make datadog` автоматически используют `ansible/vault-password`.

## Подготовка серверов

```bash
make galaxy
make install
make ping
```

## Деплой приложения

```bash
make deploy
```

Команда `make deploy` запускает только задачи с тегом `redmine` (конфигурация и контейнер Redmine).

## Мониторинг (Datadog)

```bash
make datadog
```

Агент устанавливается на хосты группы `webservers`. HTTP-проверка настроена в `group_vars/webservers/vars.yml` и обращается к `http://{{ ansible_host }}:{{ redmine_port }}`.

В Security Group VM разрешён HTTP на порт 80:
- от ALB (для балансировщика)
- с публичных IP (для Datadog `http_check`)

## Проверка и тесты

```bash
make lint
make ping
```

Автоматические тесты Hexlet запускаются в GitHub Actions при каждом push.

Проверка доступности:

- Приложение через ALB: https://task6.devops-campus.ru
- Redmine на серверах: `http://<vm-public-ip>`

## Команды Makefile

| Команда | Описание |
|---|---|
| `make help` | Список доступных команд |
| `make galaxy` | Установка ролей Ansible Galaxy |
| `make lint` | Проверка playbook (`ansible-lint`) |
| `make ping` | Проверка SSH-подключения |
| `make install` | Установка pip и Docker |
| `make deploy` | Деплой Redmine |
| `make datadog` | Установка агента Datadog |
| `make vault-edit` | Редактирование секретов |
| `make vault-encrypt` | Шифрование vault-файла |
| `make vault-view` | Просмотр секретов |

## Полезные ссылки

- [Redmine Docker Image](https://hub.docker.com/_/redmine)
- [Ansible Documentation](https://docs.ansible.com/)
- [Datadog](https://www.datadoghq.com/)
- [Yandex Application Load Balancer](https://yandex.cloud/ru/docs/application-load-balancer/)
- [Yandex Managed PostgreSQL](https://yandex.cloud/ru/docs/managed-postgresql/)
