# Настройка MongoDB с шардированием и репликацией

## Структура кластера
- 1 конфигурационный сервер (configsvr1)
- 2 шарда, каждый с 3 репликами (primary + 2 secondary)
- 1 маршрутизатор (mongos)

## Шаги по настройке

### 1. Запуск контейнеров
```bash
docker-compose up -d
```

### 2. Настройка конфигурационного сервера
```bash
docker exec -it configsvr1 mongosh --eval '
rs.initiate({
  _id: "configReplSet",
  members: [{ _id: 0, host: "configsvr1:27017" }]
})
'
```

### 3. Настройка первого шарда (shard1)
```bash
# Подключение к primary
docker exec -it shard1_primary mongosh --eval '
rs.initiate({
  _id: "shard1",
  members: [
    { _id: 0, host: "shard1_primary:27017" },
    { _id: 1, host: "shard1_secondary1:27017" },
    { _id: 2, host: "shard1_secondary2:27017" }
  ]
})
'
```

### 4. Настройка второго шарда (shard2)
```bash
# Подключение к primary
docker exec -it shard2_primary mongosh --eval '
rs.initiate({
  _id: "shard2",
  members: [
    { _id: 0, host: "shard2_primary:27017" },
    { _id: 1, host: "shard2_secondary1:27017" },
    { _id: 2, host: "shard2_secondary2:27017" }
  ]
})
'
```

### 5. Добавление шардов в кластер
```bash
# Подключение к mongos
docker exec -it mongos mongosh --eval '
sh.addShard("shard1/shard1_primary:27017")
sh.addShard("shard2/shard2_primary:27017")
'
```

### 6. Включение шардирования для базы данных
```bash
# Подключение к mongos
docker exec -it mongos mongosh --eval '
sh.enableSharding("somedb")
'
```

### 7. Настройка ключа шардирования
```bash
# Подключение к mongos
docker exec -it mongos mongosh --eval '
sh.shardCollection("somedb", { "shard_key": 1 })
'
```

## Проверка статуса
- Проверка статуса репликации: `rs.status()`
- Проверка статуса шардирования: `sh.status()`

## Подключение к кластеру
Для подключения к кластеру используйте строку подключения:
```
mongodb://mongos:27024
```

## Примечания
- Все порты доступны на localhost
- Для отказоустойчивости рекомендуется использовать отдельные хосты для каждой реплики
- Рекомендуется настроить аутентификацию для безопасности

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

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
