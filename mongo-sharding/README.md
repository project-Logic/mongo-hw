# Настройка MongoDB с шардированием

## Структура кластера
- 3 конфигурационных сервера (configsvr1, configsvr2, configsvr3)
- 3 шарда (shard1, shard2, shard3)
- 2 маршрутизатора (mongos1, mongos2)

## Шаги по настройке

### 1. Запуск контейнеров
```bash
docker-compose up -d
```

### 2. Настройка конфигурационных серверов
```bash
docker exec -it configsvr1 mongosh --eval '
rs.initiate({
  _id: "configReplSet",
  members: [
    { _id: 0, host: "configsvr1:27017" },
    { _id: 1, host: "configsvr2:27017" },
    { _id: 2, host: "configsvr3:27017" }
  ]
})
'
```

### 3. Добавление шардов в кластер
```bash
# Подключение к первому mongos
docker exec -it mongos1 mongosh --eval '
sh.addShard("shard1:27017")
sh.addShard("shard2:27017")
sh.addShard("shard3:27017")
'
```

### 4. Включение шардирования для базы данных
```bash
# Подключение к mongos
docker exec -it mongos1 mongosh --eval '
sh.enableSharding("somedb")
'
```

### 5. Настройка ключа шардирования
```bash
# Подключение к mongos
docker exec -it mongos1 mongosh --eval '
sh.shardCollection("somedb", { "shard_key": 1 })
'
```

## Проверка статуса
- Проверка статуса шардирования: `sh.status()`
- Проверка распределения данных: `db.somedb.getShardDistribution()`

### Подсчет документов в шардах
Для подсчета количества документов в каждом шарде и общего количества документов в кластере можно использовать скрипт:
```bash
chmod +x scripts/count-documents.sh
./scripts/count-documents.sh
```

Скрипт покажет:
- Количество документов в каждом шарде отдельно
- Общее количество документов через mongos

## Подключение к кластеру
Для подключения к кластеру используйте строку подключения:
```
mongodb://mongos1:27023,mongos2:27024
```

## Примечания
- Все порты доступны на localhost
- Для отказоустойчивости рекомендуется использовать отдельные хосты для каждого компонента
- Рекомендуется настроить аутентификацию для безопасности
- В данной конфигурации используется 2 маршрутизатора для балансировки нагрузки

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
