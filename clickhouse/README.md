# Локальный Clickhouse cluster

Запуск `docker-compose up -d`. Остановка `docker-compose down`.
Посмотреть логи `docker-compose logs`.

Подключиться к базе `docker exec -it clickhouse01 clickhouse-client`. Доступно 3 хоста clickhouse01-03.

Имя кластера: `cluster_ch` (см. config.xml в macros->cluster).

Имя пользователя для подключения `default` и пароль ``.



### Только для локального тестирования.


## Порядок инициализации базы данных и таблиц

На каждом узле clickhouse выполнить
1. Создать базу unified_logs.
1. Создать в ней таблицу logs_local (на каждом узле).
1. Создать в ней таблицу logs (на каждом узле).

После этого можно вставлять данные в logs, и они автоматически распределятся по кластеру.

Инициализация кластера

        docker-compose exec -T clickhouse01 clickhouse-client -n < ./setup/init_cluster.sql


### Обратите внимание

Применяется [режим сжатия ZSTD](https://clickhouse.com/docs/ru/data-compression/compression-modes) для сжатия данных в столбцах, 
он требует больше CPU. Если у вас нет проблем с местом для логов, то можно применить менее требовательный режим, напрмер, LZ4. 
