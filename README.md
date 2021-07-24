### Hexlet tests and linter status:
[![Actions Status](https://github.com/dzencot/devops-for-programmers-project-lvl3/workflows/hexlet-check/badge.svg)](https://github.com/dzencot/devops-for-programmers-project-lvl3/actions)

<a name="description"></a>
## Описание
Готовый инструмент для разворачивания инфраструктуры на AWS и приложения из публичного докерхаба.

<a name="requirements"></a>
## Требования
- Make
- Terraform 1.0.2 или выше
- Ansible 2.9.8 или выше

<a name="instruction"></a>
## Инструкция

* Склонируйте проект. Все команды должны выпоняться в директории проекта.

* Замените ключи `datadog` и данные для доступа в докерхаб в `./ansible/group_vars/`. Используйте `ansible-vault encrypt_string` чтобы закодировать секретные данные. Сохраните файл с паролем в домашней директории `~/.ansible_pass.txt`.

* Подготовьте `workspace` в [Terraform Cloud](https://app.terraform.io/). Заполните необходимые поля в `./terraform/backend.hcl`.

* Добавьте файл `./terraform/.aws/creds` для доступа к AWS [Подробнее](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

* Установите зависимости
```shell
make install
```

* Инициализируйте Terraform
```shell
make terrafrom-init
```

* Замените публичный `ip` в `./ansible/inventory.ini` на тот, который будет создан через терраформ.

* Запустите подготовку сервера и деплой приложения
```shell
make playbook-run
```

* Проверьте работу приложения по тому адресу, который указали в инвентори-файле.

<a name="link"></a>
## Пример
http://dzencot.xyz/
