#!/bin/bash

echo "Подсчет документов в шардах..."

# Подсчет документов в shard1
echo "Шард 1:"
docker exec -it shard1 mongosh --eval '
db = db.getSiblingDB("somedb")
db.somedb.countDocuments()
'

# Подсчет документов в shard2
echo "Шард 2:"
docker exec -it shard2 mongosh --eval '
db = db.getSiblingDB("somedb")
db.somedb.countDocuments()
'

# Общее количество документов через mongos
echo "Общее количество документов (через mongos):"
docker exec -it mongos1 mongosh --eval '
db = db.getSiblingDB("somedb")
db.somedb.countDocuments()
' 