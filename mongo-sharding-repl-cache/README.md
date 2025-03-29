# MongoDB Sharding с репликацией и кешированием

Этот проект демонстрирует настройку MongoDB в режиме шардинга с репликацией и кешированием через Redis.

## Архитектура

- 1 Config Server (configsvr1)
- 2 шарда с репликацией:
  - Shard1: primary + secondary
  - Shard2: primary + secondary
- Mongos Router
- Redis для кеширования
- API приложение на FastAPI

## Предварительные требования

- Docker и Docker Compose
- Python 3.12+
- pip (менеджер пакетов Python)

## Порты

- Config Server: 27017
- Shard1 Primary: 27018
- Shard1 Secondary: 27019
- Shard2 Primary: 27020
- Shard2 Secondary: 27021
- Mongos: 27024
- Redis: 6379
- API: 8080

## Запуск кластера

1. Запустите контейнеры:
```bash
docker compose up -d
```

2. Инициализируйте Config Server ReplicaSet:
```bash
docker exec -it configsvr1 mongosh --eval "rs.initiate({ _id: 'configReplSet', members: [{ _id: 0, host: 'configsvr1:27017' }] })"
```

3. Инициализируйте Shard1 ReplicaSet:
```bash
docker exec -it shard1_primary mongosh --eval "rs.initiate({ _id: 'shard1', members: [{ _id: 0, host: 'shard1_primary:27017' }, { _id: 1, host: 'shard1_secondary:27017' }] })"
```

4. Инициализируйте Shard2 ReplicaSet:
```bash
docker exec -it shard2_primary mongosh --eval "rs.initiate({ _id: 'shard2', members: [{ _id: 0, host: 'shard2_primary:27017' }, { _id: 1, host: 'shard2_secondary:27017' }] })"
```

5. Добавьте шарды в кластер через mongos:
```bash
docker exec -it mongos mongosh --eval "sh.addShard('shard1/shard1_primary:27017')"
docker exec -it mongos mongosh --eval "sh.addShard('shard2/shard2_primary:27017')"
```

6. Включите шардинг для базы данных:
```bash
docker exec -it mongos mongosh --eval "sh.enableSharding('somedb')"
```

7. Настройте ключ шардирования для коллекции:
```bash
docker exec -it mongos mongosh --eval "sh.shardCollection('somedb.helloDoc', { 'shard_key': 'hashed' })"
```

## Загрузка тестовых данных

1. Установите зависимости Python:
```bash
pip install -r scripts/requirements.txt
```

2. Запустите скрипт для генерации и загрузки данных:
```bash
python scripts/generate_data.py
```

Скрипт создаст 1000 тестовых документов со следующими полями:
- shard_key: уникальный идентификатор документа
- value: текстовое описание документа
- timestamp: время создания документа

## Инициализация Redis

1. Проверьте, что Redis запущен:
```bash
docker exec -it redis redis-cli ping
```

2. Установите максимальный размер памяти для Redis (например, 1GB):
```bash
docker exec -it redis redis-cli config set maxmemory 1gb
```

3. Установите политику очистки памяти (например, allkeys-lru):
```bash
docker exec -it redis redis-cli config set maxmemory-policy allkeys-lru
```

4. Установите время жизни кеша по умолчанию (например, 300 секунд):
```bash
docker exec -it redis redis-cli config set default-ttl 300
```

5. Проверьте настройки Redis:
```bash
docker exec -it redis redis-cli config get maxmemory
docker exec -it redis redis-cli config get maxmemory-policy
docker exec -it redis redis-cli config get default-ttl
```

## Проверка распределения данных

1. Проверьте общее количество документов через mongos:
```bash
docker exec -it mongos mongosh --eval "db.helloDoc.count()"
```

2. Проверьте количество документов в каждом шарде:
```bash
# Shard1
docker exec -it shard1_primary mongosh --eval "db.helloDoc.count()"
docker exec -it shard1_secondary mongosh --eval "db.helloDoc.count()"

# Shard2
docker exec -it shard2_primary mongosh --eval "db.helloDoc.count()"
docker exec -it shard2_secondary mongosh --eval "db.helloDoc.count()"
```

3. Проверьте распределение данных по шардам:
```bash
docker exec -it mongos mongosh --eval "db.helloDoc.getShardDistribution()"
```

## Проверка репликации

1. Проверьте статус репликации Shard1:
```bash
docker exec -it shard1_primary mongosh --eval "rs.status()"
```

2. Проверьте статус репликации Shard2:
```bash
docker exec -it shard2_primary mongosh --eval "rs.status()"
```

## Проверка Redis

1. Проверьте подключение к Redis:
```bash
docker exec -it redis redis-cli ping
```

2. Проверьте статистику Redis:
```bash
docker exec -it redis redis-cli info
```

3. Проверьте количество ключей в Redis:
```bash
docker exec -it redis redis-cli dbsize
```

4. Проверьте время жизни кеша (TTL) для конкретного ключа:
```bash
docker exec -it redis redis-cli ttl "your_key"
```

## Остановка и очистка

Для остановки и удаления всех контейнеров и томов:
```bash
docker compose down -v
```

## Примечания

- Все сервисы находятся в одной Docker сети (app-network) с фиксированными IP-адресами
- Настроены healthcheck для всех сервисов
- API приложение использует Redis для кеширования
- Шарды настроены с репликацией для отказоустойчивости

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
