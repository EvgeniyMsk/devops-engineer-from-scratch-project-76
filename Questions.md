# Экзамен по Ansible — 35 вопросов и ответов

Вопросы расположены от простых к сложным. Рекомендуется проходить последовательно.

---

## Уровень 1: Основы (вопросы 1–7)

### 1. Что такое Ansible и для чего он используется?

**Ответ:** Ansible — это инструмент автоматизации конфигурации, развёртывания приложений и оркестрации IT-инфраструктуры. Он использует декларативный подход: вы описываете желаемое состояние системы, а Ansible приводит хосты к этому состоянию. Работает по SSH (или WinRM для Windows), не требует агента на управляемых узлах.

---

### 2. В чём разница между control node и managed node?

**Ответ:**
- **Control node** — машина, с которой запускается Ansible (где установлен `ansible` или `ansible-playbook`). На ней выполняются playbooks и модули.
- **Managed node** — удалённый хост, который Ansible настраивает. На нём нужен только Python и SSH-доступ; отдельный агент Ansible не устанавливается.

---

### 3. Что такое inventory и какие форматы он поддерживает?

**Ответ:** Inventory — это список управляемых хостов и их группировка. Ansible использует inventory, чтобы знать, на каких машинах выполнять задачи.

Поддерживаемые форматы:
- INI (классический, например `inventory.ini`)
- YAML (например `inventory.yml`)
- Динамический inventory (скрипты или плагины, например для AWS, Azure, VMware)

Пример INI:
```ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com
```

---

### 4. Что такое playbook и из каких основных элементов он состоит?

**Ответ:** Playbook — YAML-файл, описывающий автоматизацию в виде одного или нескольких **play**. Каждый play содержит:
- **hosts** — целевые хосты или группы
- **tasks** — список действий (модулей)
- опционально: **vars**, **handlers**, **roles**, **pre_tasks**, **post_tasks**, **tags**

Пример:
```yaml
- hosts: webservers
  tasks:
    - name: Ensure nginx is installed
      ansible.builtin.package:
        name: nginx
        state: present
```

---

### 5. Что такое модуль в Ansible?

**Ответ:** Модуль — это единица работы, которую Ansible выполняет на managed node. Модули инкапсулируют конкретное действие: установка пакета, копирование файла, управление сервисом и т.д.

Примеры:
- `ansible.builtin.copy` — копирование файлов
- `ansible.builtin.service` — управление systemd-сервисами
- `ansible.builtin.apt` — работа с пакетным менеджером APT

Модули должны быть **идемпотентными**: повторный запуск не меняет систему, если желаемое состояние уже достигнуто.

---

### 6. Чем отличаются команды `ansible` и `ansible-playbook`?

**Ответ:**
- **`ansible`** — ad-hoc команда для разовых задач из CLI без playbook.
  ```bash
  ansible webservers -m ping
  ansible all -m ansible.builtin.apt -a "name=nginx state=present" -b
  ```
- **`ansible-playbook`** — запуск playbook-файла с набором play и задач.
  ```bash
  ansible-playbook site.yml
  ```

Ad-hoc удобен для быстрых проверок; playbook — для воспроизводимой автоматизации.

---

### 7. Что делает модуль `ping` и почему он не проверяет ICMP?

**Ответ:** Модуль `ansible.builtin.ping` проверяет доступность хоста и возможность выполнить Python-код через Ansible. Он возвращает `pong`, если соединение и права работают.

Название историческое: это не ICMP ping, а проверка SSH-сессии и Python-интерпретатора на удалённой машине.

---

## Уровень 2: Синтаксис и переменные (вопросы 8–14)

### 8. Что такое факты (facts) в Ansible?

**Ответ:** Facts — автоматически собираемая информация о managed node: ОС, IP-адреса, диски, сеть, версия ядра и т.д. Собираются модулем `setup` (выполняется неявно в начале play, если не отключено).

Примеры использования:
```yaml
when: ansible_facts.os_family == 'Debian'
{{ ansible_facts['default_ipv4']['address'] }}
```

Отключение сбора фактов:
```yaml
gather_facts: false
```

---

### 9. Какие способы определения переменных в Ansible вы знаете?

**Ответ:** Переменные можно задать через:
1. **Playbook vars** — секция `vars` в play
2. **Inventory** — переменные хоста или группы
3. **group_vars/** и **host_vars/** — файлы рядом с inventory
4. **Role defaults** (`defaults/main.yml`) и **role vars** (`vars/main.yml`)
5. **Extra vars** — `-e` / `--extra-vars` (наивысший приоритет)
6. **Registered variables** — результат задачи через `register`
7. **Facts** — `ansible_facts`
8. **Include vars** — `include_vars`, `vars_files`

---

### 10. Как работает приоритет переменных в Ansible?

**Ответ:** Чем «ближе» переменная к конкретному play/task и чем позже она определена, тем выше приоритет. Упрощённо (от низкого к высокому):

1. Role defaults
2. Inventory group_vars / host_vars
3. Play vars
4. Role vars
5. Block vars
6. Task vars
7. Include vars / registered / facts
8. **Extra vars (`-e`)** — всегда побеждают

На практике при конфликте побеждает переменная с более высоким приоритетом.

---

### 11. Что такое Jinja2-шаблоны и где они используются в Ansible?

**Ответ:** Jinja2 — шаблонизатор для подстановки переменных и логики в текст. В Ansible используется в:
- playbook и inventory (`{{ variable }}`, `{% if %}`)
- модуле `template` — генерация конфигов на хостах
- conditionals (`when`)

Пример:
```yaml
- name: Deploy nginx config
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
```

В шаблоне:
```jinja2
server_name {{ ansible_facts.fqdn }};
{% if enable_ssl %}
listen 443 ssl;
{% endif %}
```

---

### 12. Что такое handlers и когда они выполняются?

**Ответ:** Handlers — специальные задачи, которые запускаются **только при изменении** (changed) другой задачей, и только **один раз в конце play**, даже если их уведомили несколько раз.

Типичный сценарий — перезапуск сервиса после изменения конфига:
```yaml
tasks:
  - name: Update nginx config
    ansible.builtin.template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: Restart nginx

handlers:
  - name: Restart nginx
    ansible.builtin.service:
      name: nginx
      state: restarted
```

---

### 13. Что означает идемпотентность в Ansible и почему она важна?

**Ответ:** Идемпотентность — свойство операции давать один и тот же результат при многократном выполнении. Если пакет уже установлен, модуль вернёт `ok`, а не `changed`.

Это важно, потому что:
- можно безопасно перезапускать playbook
- легче отслеживать реальные изменения в CI/CD
- снижается риск «дрейфа» конфигурации

---

### 14. Что такое `become` и чем отличается от флага `-b`?

**Ответ:** `become` — механизм повышения привилегий (sudo, su, runas). Позволяет выполнять задачи от имени другого пользователя, обычно root.

```yaml
- hosts: all
  become: true
  become_user: root
  become_method: sudo
  tasks:
    - name: Install package
      ansible.builtin.apt:
        name: htop
        state: present
```

Флаг `-b` в CLI — сокращение для `--become`, включает повышение привилегий для ad-hoc или playbook.

---

## Уровень 3: Структура и организация (вопросы 15–21)

### 15. Что такое role и из каких каталогов она состоит?

**Ответ:** Role — переиспользуемый набор задач, переменных, шаблонов и файлов для определённой функции (например, `nginx`, `docker`).

Стандартная структура:
```
roles/myrole/
├── defaults/main.yml   # переменные с низким приоритетом
├── vars/main.yml       # переменные роли
├── tasks/main.yml      # основные задачи
├── handlers/main.yml   # обработчики
├── templates/          # Jinja2-шаблоны
├── files/              # статические файлы
├── meta/main.yml       # зависимости роли
└── README.md
```

Подключение:
```yaml
roles:
  - myrole
```

---

### 16. Чем отличаются `defaults/main.yml` и `vars/main.yml` в роли?

**Ответ:**
- **`defaults/main.yml`** — переменные по умолчанию с **низким приоритетом**. Их легко переопределить из playbook, inventory или extra vars. Предназначены для настраиваемых параметров роли.
- **`vars/main.yml`** — переменные с **более высоким приоритетом**, обычно внутренние константы роли, которые не предполагается менять снаружи.

Правило: всё, что пользователь роли может настроить — в `defaults`; внутренние значения — в `vars`.

---

### 17. Что такое `ansible.cfg` и какие ключевые параметры там настраивают?

**Ответ:** `ansible.cfg` — конфигурационный файл Ansible. Ищется в порядке: `ANSIBLE_CONFIG` → `./ansible.cfg` → `~/.ansible.cfg` → `/etc/ansible/ansible.cfg`.

Частые параметры:
```ini
[defaults]
inventory = ./inventories/inventory.ini
remote_user = ubuntu
host_key_checking = False
roles_path = ./roles
retry_files_enabled = False

[privilege_escalation]
become = True
become_method = sudo
```

---

### 18. Что такое tags и зачем они нужны?

**Ответ:** Tags — метки задач, play или role для выборочного запуска части playbook.

```yaml
- name: Install nginx
  ansible.builtin.apt:
    name: nginx
    state: present
  tags:
    - install
    - nginx
```

Запуск:
```bash
ansible-playbook site.yml --tags nginx
ansible-playbook site.yml --skip-tags install
```

Полезно для ускорения деплоя и разделения этапов (install / config / deploy).

---

### 19. Что такое `pre_tasks` и `post_tasks`?

**Ответ:** Это задачи, выполняемые до или после основного блока `roles`/`tasks` в play.

- **pre_tasks** — подготовка: обновление кэша пакетов, проверки, создание пользователей
- **post_tasks** — финальные действия: запуск приложения, уведомления, проверки health

```yaml
- hosts: webservers
  pre_tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true
  roles:
    - nginx
  post_tasks:
    - name: Verify nginx is running
      ansible.builtin.uri:
        url: http://localhost
```

---

### 20. Как организовать inventory с группами и вложенными группами?

**Ответ:** Группы объединяют хосты; группы могут включать другие группы через `:children`.

INI:
```ini
[webservers]
web1
web2

[dbservers]
db1

[production:children]
webservers
dbservers

[production:vars]
env=prod
```

YAML:
```yaml
all:
  children:
    webservers:
      hosts:
        web1:
        web2:
    production:
      children:
        webservers:
      vars:
        env: prod
```

---

### 21. Что такое `requirements.yml` и для чего он используется?

**Ответ:** `requirements.yml` — файл для установки внешних ролей и коллекций Ansible.

```yaml
roles:
  - name: geerlingguy.docker
    version: "7.0.2"

collections:
  - name: community.docker
    version: ">=3.0.0"
```

Установка:
```bash
ansible-galaxy role install -r requirements.yml
ansible-galaxy collection install -r requirements.yml
```

Это стандартный способ фиксировать зависимости автоматизации.

---

## Уровень 4: Практические сценарии (вопросы 22–28)

### 22. Как работает модуль `copy` и чем он отличается от `template`?

**Ответ:**
- **`copy`** — копирует статический файл из `files/` (или по `src`) на хост без обработки Jinja2.
- **`template`** — обрабатывает Jinja2-шаблон (`.j2`) и генерирует итоговый файл с подставленными переменными.

`copy` — когда файл одинаков для всех; `template` — когда содержимое зависит от хоста, окружения или переменных.

---

### 23. Что такое `register` и `set_fact`?

**Ответ:**
- **`register`** — сохраняет результат выполнения задачи в переменную для последующих задач.
  ```yaml
  - name: Check if app exists
    ansible.builtin.stat:
      path: /opt/app
    register: app_dir

  - name: Create app dir
    ansible.builtin.file:
      path: /opt/app
      state: directory
    when: not app_dir.stat.exists
  ```

- **`set_fact`** — создаёт или переопределяет переменную в runtime play.
  ```yaml
  - ansible.builtin.set_fact:
      deploy_version: "{{ lookup('env', 'CI_COMMIT_SHA') }}"
  ```

---

### 24. Как использовать условия `when` и логические операторы?

**Ответ:** `when` выполняет задачу только при истинном условии.

```yaml
- name: Install on Debian
  ansible.builtin.apt:
    name: nginx
    state: present
  when: ansible_facts.os_family == 'Debian'

- name: Restart only if changed
  ansible.builtin.service:
    name: nginx
    state: restarted
  when: config_changed is changed
```

Поддерживаются:
- сравнения: `==`, `!=`, `>`, `<`
- логика: `and`, `or`, `not`
- проверка наличия: `variable is defined`
- списки: `item in my_list`

---

### 25. Что такое loops в Ansible и чем `loop` отличается от `with_items`?

**Ответ:** Loops позволяют выполнить одну задачу для каждого элемента списка.

Современный синтаксис:
```yaml
- name: Create users
  ansible.builtin.user:
    name: "{{ item.name }}"
    groups: "{{ item.groups }}"
  loop:
    - { name: alice, groups: developers }
    - { name: bob, groups: admins }
```

`with_items` — устаревший синтаксис; рекомендуется `loop`. Для dict используют `loop` + `{{ item.key }}` / `{{ item.value }}` или `dict2items`.

---

### 26. Как работает Ansible Vault?

**Ответ:** Ansible Vault шифрует чувствительные данные (пароли, ключи, токены) в YAML-файлах.

Создание зашифрованного файла:
```bash
ansible-vault create secrets.yml
```

Редактирование:
```bash
ansible-vault edit secrets.yml
```

Запуск playbook:
```bash
ansible-vault encrypt group_vars/all/vault.yml
ansible-playbook site.yml --ask-vault-pass
ansible-playbook site.yml --vault-password-file ~/.vault_pass
```

В playbook переменные из vault используются как обычные:
```yaml
db_password: "{{ vault_db_password }}"
```

---

### 27. Что такое `--check` (dry-run) и `--diff`?

**Ответ:**
- **`--check`** — режим проверки без реальных изменений. Ansible показывает, что *бы* изменилось. Не все модули полностью поддерживают check mode.
- **`--diff`** — показывает различия в файлах при изменениях (удобно с `template`, `copy`, `lineinfile`).

```bash
ansible-playbook site.yml --check --diff
```

Полезно перед продакшен-деплоем для ревью изменений.

---

### 28. Как обрабатывать ошибки с помощью `block`, `rescue` и `always`?

**Ответ:** Конструкция похожа на try/except/finally:

```yaml
- name: Safe deployment
  block:
    - name: Deploy app
      ansible.builtin.command: /opt/deploy.sh
  rescue:
    - name: Rollback on failure
      ansible.builtin.command: /opt/rollback.sh
  always:
    - name: Notify team
      ansible.builtin.debug:
        msg: "Deployment attempt finished"
```

- **block** — основные задачи
- **rescue** — выполняется при ошибке в block
- **always** — выполняется всегда, независимо от результата

---

## Уровень 5: Продвинутые темы (вопросы 29–35)

### 29. Что такое Ansible Collections и зачем они нужны?

**Ответ:** Collections — способ распространять модули, плагины, роли и playbook в едином пакете. Начиная с Ansible 2.10+, многие модули вынесены из ядра в collections (например, `community.general`, `community.docker`, `amazon.aws`).

Установка:
```bash
ansible-galaxy collection install community.docker
```

Использование:
```yaml
- community.docker.docker_container:
    name: myapp
    image: nginx:latest
    state: started
```

Collections позволяют независимо версионировать и развивать функциональность.

---

### 30. Что такое dynamic inventory и когда его используют?

**Ответ:** Dynamic inventory автоматически формирует список хостов из внешнего источника (облако, CMDB, Kubernetes), а не из статического файла.

Примеры:
- `ansible-inventory -i aws_ec2.yml --graph`
- плагины inventory для Yandex Cloud, AWS, Azure

Используют когда:
- инфраструктура часто меняется (autoscaling)
- много хостов в облаке
- нужна актуальная информация без ручного обновления inventory

---

### 31. Как работает `delegate_to` и `run_once`?

**Ответ:**
- **`delegate_to`** — выполняет задачу на другом хосте, не на текущем из play.
  ```yaml
  - name: Add host to load balancer
    community.general.haproxy:
      host: "{{ inventory_hostname }}"
      state: enabled
    delegate_to: lb-server
  ```

- **`run_once`** — задача выполняется один раз для всего play, результат доступен через `hostvars`.
  ```yaml
  - name: Get database version
    ansible.builtin.command: psql --version
    register: db_version
    run_once: true
  ```

Часто используются для балансировщиков, общих БД, CI/CD-оркестрации.

---

### 32. Что такое callback plugins и зачем нужен `ansible.builtin.profile_tasks`?

**Ответ:** Callback plugins управляют выводом Ansible в консоль или лог.

Примеры:
- `default` — стандартный вывод
- `yaml` — структурированный YAML-вывод
- `profile_tasks` — показывает время выполнения каждой задачи

Включение в `ansible.cfg`:
```ini
[defaults]
callbacks_enabled = timer, profile_tasks
```

Помогает находить «медленные» задачи и оптимизировать playbook.

---

### 33. Как тестировать Ansible-роли с Molecule?

**Ответ:** Molecule — фреймворк для тестирования ролей. Обычно использует Docker/Vagrant как платформу, запускает роль и проверяет результат.

Типичный цикл:
```bash
molecule create    # создать тестовые инстансы
molecule converge  # применить роль
molecule verify    # проверить (testinfra, ansible verify playbook)
molecule destroy   # удалить инстансы
```

Структура:
```
molecule/default/
├── molecule.yml   # конфигурация
├── converge.yml   # playbook для применения роли
└── verify.yml     # проверки
```

Это best practice для CI/CD и качества ролей.

---

### 34. Как оптимизировать производительность Ansible?

**Ответ:** Основные техники:

1. **Параллелизм** — `-f` / `forks` (по умолчанию 5)
2. **SSH pipelining** — `pipelining = True` в `ansible.cfg`
3. **Fact caching** — `fact_caching = jsonfile` для повторных запусков
4. **Mitogen** (опционально) — ускорение SSH
5. **Tags** — запуск только нужных задач
6. **`serial`** — контролируемый rolling update вместо одновременного деплоя на все хосты
7. **Async tasks** — для длительных операций без блокировки
8. **Отключение facts** — `gather_facts: false`, если не нужны

Пример rolling update:
```yaml
- hosts: webservers
  serial: "25%"
  tasks:
    - name: Deploy
      ...
```

---

### 35. Объясните стратегию Blue-Green или Rolling deployment в Ansible и приведите пример с `serial` и `max_fail_percentage`.

**Ответ:** При деплое на кластер важно минимизировать downtime и риск массового сбоя.

**Rolling deployment** — обновление хостов партиями. Ansible параметр `serial` задаёт размер партии:
```yaml
- hosts: webservers
  serial: 2          # по 2 хоста за раз
  max_fail_percentage: 25
  tasks:
    - name: Pull new image
      community.docker.docker_image:
        name: myapp:{{ version }}
        source: pull

    - name: Restart container
      community.docker.docker_container:
        name: myapp
        image: myapp:{{ version }}
        state: started
        recreate: true

    - name: Wait for health check
      ansible.builtin.uri:
        url: http://{{ inventory_hostname }}/health
        status_code: 200
      retries: 5
      delay: 10
```

- **`serial: 2`** — обновляет по 2 сервера, остальные продолжают обслуживать трафик
- **`max_fail_percentage: 25`** — play прервётся, если более 25% хостов в текущей партии упали с ошибкой

**Blue-Green** в чистом виде Ansible не реализует (нужен балансировщик и переключение трафика), но Ansible может:
1. Развернуть green-окружение (`delegate_to`, отдельная группа)
2. Прогнать smoke-тесты
3. Переключить балансировщик (`haproxy`, `nginx` upstream)
4. Остановить blue

Ключевая идея: контролируемые партии + health checks + возможность остановки при превышении порога ошибок.

---

## Рекомендации для экзаменуемого

| Уровень | Вопросы | Ожидания |
|---------|---------|----------|
| Junior  | 1–14    | Понимание базовых концепций, синтаксиса, переменных |
| Middle  | 15–28   | Структура проектов, roles, vault, практические модули |
| Senior  | 29–35   | Collections, тестирование, оптимизация, стратегии деплоя |

Удачи на экзамене!
