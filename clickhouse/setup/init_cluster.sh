#!/bin/bash

# Параметры подключения (можно передавать через аргументы)
CLICKHOUSE_HOST="clickhouse01"  # или localhost, если выполняется на одном из узлов
CLICKHOUSE_USER="default"       # или другой пользователь

# Проверяем, установлен ли clickhouse-client
if ! command -v clickhouse-client &> /dev/null; then
    echo "Ошибка: clickhouse-client не установлен или не добавлен в PATH."
    exit 1
fi

# Выполняем SQL-запросы из файла
echo "Развёртывание кластера ClickHouse..."
clickhouse-client \
    --host="$CLICKHOUSE_HOST" \
    --user="$CLICKHOUSE_USER" \
    --multiquery < ./init_cluster.sql

if [ $? -eq 0 ]; then
    echo "✅ Успех: база unified_logs и таблицы logs/logs_local создана или обновлена успешно."
else
    echo "❌ Ошибка: не удалось выполнить запросы. Проверьте подключение и логи ClickHouse."
    exit 1
fi
