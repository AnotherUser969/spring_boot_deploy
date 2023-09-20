Порядок конфигурирования jenkins сервера:
````
#!bin/bash
#Добавление jenkins репозитория
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
#Установка java и jenkins
sudo apt install openjdk-17-jre -y && sudo apt install jenkins -y
# Добавление репозитория ansible и его установка
sudo apt-add-repository ppa:ansible/ansible -y && sudo apt install ansible -y
# Установка необходимых в будущем утилит
sudo apt install jq unzip -y
# Скачивание terraform с зеркала yandex cloud в директорию /opt
sudo wget https://hashicorp-releases.yandexcloud.net/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -P /opt
# Распаковка и удаление исходного архива
sudo unzip /opt/terraform_1.5.7_linux_amd64.zip && sudo rm /opt/terraform_1.5.7_linux_amd64.zip
````

На сервере jenkins необходимо загрузить следующие плагины:
- terraform
- asnible
- sshagent

И добавить необходимые credentials:
- SA_ACCESS_KEY (идентификатор ключа в облаке)
- SA_SECRET_KEY (секретный ключ в облаке)
- KEY_FILE (авторизованный ключ для сервисного аккаунта)
- SSH_KEY (ssh ключ и логин для созданный инстансов)

Установка yandex cli:
````
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
````
Инициализация в облаке:
````
yc init
````
Получение ACCESS_KEY и SECRET_KEY:
````
yc iam access-key create --service-account-name sa-terraform \
  --description "this key is for my bucket"
````
Получение ключа для сервисного аккаунта:

Вывести список аккаунтов:
````
yc iam service-account list
````
Создание ключа:
````
yc iam key create \
  --service-account-id "<id сервисного аккаунта>" \
  --folder-name "<имя папки в облаке>" \
  --output key.json
````
