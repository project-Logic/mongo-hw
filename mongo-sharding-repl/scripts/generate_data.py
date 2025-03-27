from pymongo import MongoClient
from datetime import datetime

# Подключение к MongoDB через mongos
client = MongoClient('mongodb://localhost:27020')
db = client.somedb
collection = db.test_collection

# Генерация 1000 документов
documents = []
for i in range(1000):
    document = {
        'shard_key': i,
        'value': f'Test document {i}',
        'timestamp': datetime.now()
    }
    documents.append(document)

# Вставка документов
result = collection.insert_many(documents)
print(f'Добавлено {len(result.inserted_ids)} документов') 