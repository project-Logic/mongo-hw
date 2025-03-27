# MongoDB Шардинг

Этот проект демонстрирует настройку MongoDB с шардингом, используя Docker Compose.

## Архитектура

- Config Server (ReplicaSet)
- 2 Шарда (каждый в режиме ReplicaSet)
- Mongos Router
- Python API приложение

## Предварительные требования

- Docker
- Docker Compose
- Python 3.x
- pip (менеджер пакетов Python)

## Запуск

1. Запустите контейнеры:
```bash
docker compose up -d
```

2. Подождите около 10 секунд и инициализируйте Config Server ReplicaSet:
```bash
docker exec -it configSrv mongosh --eval "rs.initiate({_id: 'config_server', members: [{_id: 0, host: 'configSrv:27017'}]})"
```

3. Подождите около 10 секунд и инициализируйте Shard1 ReplicaSet:
```bash
docker exec -it shard1 mongosh --port 27018 --eval "rs.initiate({_id: 'shard1', members: [{_id: 0, host: 'shard1:27018'}]})"
```

4. Подождите около 10 секунд и инициализируйте Shard2 ReplicaSet:
```bash
docker exec -it shard2 mongosh --port 27019 --eval "rs.initiate({_id: 'shard2', members: [{_id: 0, host: 'shard2:27019'}]})"
```

5. Подождите около 10 секунд и добавьте шарды в кластер через mongos:
```bash
docker exec -it mongos_router mongosh --port 27020 --eval "sh.addShard('shard1/shard1:27018'); sh.addShard('shard2/shard2:27019')"
```

6. Включите шардинг для базы данных:
```bash
docker exec -it mongos_router mongosh --port 27020 --eval "sh.enableSharding('somedb')"
```

7. Настройте ключ шардирования для коллекции:
```bash
docker exec -it mongos_router mongosh --port 27020 --eval "sh.shardCollection('somedb.test_collection', { 'shard_key': 1 })"
```

## Загрузка тестовых данных

1. Установите зависимости Python:
```bash
cd scripts
pip install -r requirements.txt
```

2. Запустите скрипт для генерации данных:
```bash
python generate_data.py
```

Скрипт создаст 1000 тестовых документов с полями:
- shard_key: уникальный идентификатор (0-999)
- value: текстовое описание документа
- timestamp: время создания документа

## Проверка распределения данных

1. Проверка общего количества документов через mongos:
```bash
docker exec -it mongos_router mongosh --port 27020 --eval "db.test_collection.count()"
```

2. Проверка количества документов в каждом шарде:
```bash
# Проверка Shard1
docker exec -it shard1 mongosh --port 27018 --eval "db.test_collection.count()"

# Проверка Shard2
docker exec -it shard2 mongosh --port 27019 --eval "db.test_collection.count()"
```

3. Проверка распределения данных по шардам:
```bash
docker exec -it mongos_router mongosh --port 27020 --eval "db.test_collection.getShardDistribution()"
```

## Проверка статуса

Чтобы проверить статус шардинга:
```bash
docker exec -it mongos_router mongosh --port 27020 --eval "sh.status()"
```

## Порты

- Config Server: 27017
- Shard1: 27018
- Shard2: 27019
- Mongos Router: 27020
- Python API: 8080

## Остановка и очистка

Для остановки и удаления всех контейнеров и томов:
```bash
docker compose down -v
```

## Подключение к кластеру
Для подключения к кластеру используйте строку подключения:
```
mongodb://mongos1:27020,mongos2:27021
```

## Примечания
- Все порты доступны на localhost
- Для отказоустойчивости рекомендуется использовать отдельные хосты для каждого компонента
- Рекомендуется настроить аутентификацию для безопасности
- В данной конфигурации используется 2 маршрутизатора для балансировки нагрузки

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs
