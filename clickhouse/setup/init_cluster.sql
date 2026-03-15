-- 1. Создаём базу данных на всех узлах кластера
CREATE DATABASE IF NOT EXISTS unified_logs ON CLUSTER 'cluster_ch';

-- 2. Создаём локальную таблицу с репликацией (ReplicatedMergeTree)
--
CREATE TABLE
       IF NOT EXISTS unified_logs.logs_local ON CLUSTER 'cluster_ch' (
              `ObservedTimestamp` DateTime64 (9) COMMENT 'Когда событие зарегистрировано системой сбора логов,
 наносекунд от начала Unix эпохи' CODEC (Delta (8), ZSTD (1)),
              `Timestamp` DateTime64 (9) COMMENT 'Когда произошло событие,
 наносекунд от начала Unix эпохи' CODEC (Delta (8), ZSTD (1)),
              `TraceId` String COMMENT 'Идентификатор трассировки как определено в https://www.w3.org/TR/trace-context/#trace-id' CODEC (ZSTD (1)),
              `SpanId` String COMMENT 'Идентификатор span из трейса,
 как определено в https://www.w3.org/TR/trace-context/#parent-id' CODEC (ZSTD (1)),
              `TraceFlags` String COMMENT 'Флаги трассировки,
 как определено в https://www.w3.org/TR/trace-context/#trace-flags' CODEC (ZSTD (1)),
              `SeverityText` LowCardinality (String) COMMENT 'Cтроковое представление серьезности (также известно как log level),
 как есть в исходном логе' CODEC (ZSTD (1)),
              `SeverityNumber` Enum8 (
                     'UNKNOWN' = 0,
                     'TRACE' = 1,
                     'TRACE2' = 2,
                     'TRACE3' = 3,
                     'TRACE4' = 4,
                     'DEBUG' = 5,
                     'DEBUG2' = 6,
                     'DEBUG3' = 7,
                     'DEBUG4' = 8,
                     'INFO' = 9,
                     'INFO2' = 10,
                     'INFO3' = 11,
                     'INFO4' = 12,
                     'WARN' = 13,
                     'WARN2' = 14,
                     'WARN3' = 15,
                     'WARN4' = 16,
                     'ERROR' = 17,
                     'ERROR2' = 18,
                     'ERROR3' = 19,
                     'ERROR4' = 20,
                     'FATAL' = 21,
                     'FATAL2' = 22,
                     'FATAL3' = 23,
                     'FATAL4' = 24
              ) DEFAULT 0 COMMENT 'Числовое значение серьезности,
 от 1 до 24',
              `ServiceName` LowCardinality (String) COMMENT 'Имя сервиса создавшего запись лога' CODEC (ZSTD (1)),
              `Body` String COMMENT 'Сообщение для человека или тело записи журнала' CODEC (ZSTD (1)),
              `Resource` Map (LowCardinality (String), String) COMMENT 'Данные о среде в которой была создана запись лога' CODEC (ZSTD (1)),
              `Attributes` Map (LowCardinality (String), String) COMMENT 'структурированные данные из записи лога (атрибуты и их значения),
 кроме TraceID,
 SpanID,
 TraceFlags' CODEC (ZSTD (1)),
              `InstrumentationScope` Map (LowCardinality (String), String) COMMENT 'Описание инструментария создавшего запись лога' CODEC (ZSTD (1)),
              `PipelineError` LowCardinality (String) COMMENT 'Название типа ошибки,
 возникшей при обработке записи в системе обработки логов' CODEC (ZSTD (1)),
              `PipelineErrorMessage` LowCardinality (String) COMMENT 'Сообщение с текстом ошибки,
 возникшей при обработке записи в системе обработки логов' CODEC (ZSTD (1)),
              `TTL` UInt16 DEFAULT 7 COMMENT 'Срок хранения записи лога в таблице в сутках,
 участвует в вычислении TTL для записи при ее добавлении в БД',
              INDEX idx_ServiceName_ObservedTimestamp (ServiceName, ObservedTimestamp) TYPE minmax GRANULARITY 8192
       ) ENGINE = ReplicatedMergeTree (
              '/clickhouse/tables/{shard}/unified_logs/logs_local',
              '{replica}'
       )
PARTITION BY
       toYYYYMMDD (ObservedTimestamp)
ORDER BY
       (
              ServiceName,
              SeverityText,
              toYYYYMMDD (ObservedTimestamp),
              toYYYYMMDDhhmmss (toStartOfHour (ObservedTimestamp)),
              ObservedTimestamp,
              TraceId
       ) TTL toDateTime (ObservedTimestamp) + toIntervalDay (TTL) SETTINGS index_granularity = 8192,
       -- включаем построченое удаление при истечении TTL
       ttl_only_drop_parts = 0;

-- 3. Создаём распределённую таблицу (Distributed)
--
-- Не хранит данные, а только проксирует запросы на локальные таблицы (logs_local) всех узлов в кластере
-- Позволяет выполнять запросы ко всем данным, как если бы они были в одной таблице.
CREATE TABLE
       IF NOT EXISTS unified_logs.logs ON CLUSTER cluster_ch (
              `ObservedTimestamp` DateTime64 (9) COMMENT 'Когда событие зарегистрировано системой сбора логов,
 наносекунд от начала Unix эпохи' CODEC (Delta (8), ZSTD (1)),
              `Timestamp` DateTime64 (9) COMMENT 'Когда произошло событие,
 наносекунд от начала Unix эпохи' CODEC (Delta (8), ZSTD (1)),
              `TraceId` String COMMENT 'Идентификатор трассировки как определено в https://www.w3.org/TR/trace-context/#trace-id' CODEC (ZSTD (1)),
              `SpanId` String COMMENT 'Идентификатор span из трейса,
 как определено в https://www.w3.org/TR/trace-context/#parent-id' CODEC (ZSTD (1)),
              `TraceFlags` String COMMENT 'Флаги трассировки,
 как определено в https://www.w3.org/TR/trace-context/#trace-flags' CODEC (ZSTD (1)),
              `SeverityText` LowCardinality (String) COMMENT 'Cтроковое представление серьезности (также известно как log level),
 как есть в исходном логе' CODEC (ZSTD (1)),
              `SeverityNumber` Enum8 (
                     'UNKNOWN' = 0,
                     'TRACE' = 1,
                     'TRACE2' = 2,
                     'TRACE3' = 3,
                     'TRACE4' = 4,
                     'DEBUG' = 5,
                     'DEBUG2' = 6,
                     'DEBUG3' = 7,
                     'DEBUG4' = 8,
                     'INFO' = 9,
                     'INFO2' = 10,
                     'INFO3' = 11,
                     'INFO4' = 12,
                     'WARN' = 13,
                     'WARN2' = 14,
                     'WARN3' = 15,
                     'WARN4' = 16,
                     'ERROR' = 17,
                     'ERROR2' = 18,
                     'ERROR3' = 19,
                     'ERROR4' = 20,
                     'FATAL' = 21,
                     'FATAL2' = 22,
                     'FATAL3' = 23,
                     'FATAL4' = 24
              ) DEFAULT 0 COMMENT 'Числовое значение серьезности,
 от 1 до 24',
              `ServiceName` LowCardinality (String) COMMENT 'Имя сервиса создавшего запись лога' CODEC (ZSTD (1)),
              `Body` String COMMENT 'Сообщение для человека или тело записи журнала' CODEC (ZSTD (1)),
              `Resource` Map (LowCardinality (String), String) COMMENT 'Данные о среде в которой была создана запись лога' CODEC (ZSTD (1)),
              `Attributes` Map (LowCardinality (String), String) COMMENT 'структурированные данные из записи лога (атрибуты и их значения),
 кроме TraceID,
 SpanID,
 TraceFlags' CODEC (ZSTD (1)),
              `InstrumentationScope` Map (LowCardinality (String), String) COMMENT 'Описание инструментария создавшего запись лога' CODEC (ZSTD (1)),
              `PipelineError` LowCardinality (String) COMMENT 'Название типа ошибки,
 возникшей при обработке записи в системе обработки логов' CODEC (ZSTD (1)),
              `PipelineErrorMessage` LowCardinality (String) COMMENT 'Сообщение с текстом ошибки,
 возникшей при обработке записи в системе обработки логов' CODEC (ZSTD (1)),
              `TTL` UInt16 COMMENT 'Срок хранения записи лога в таблице в сутках,
 участвует в вычислении TTL для записи при ее добавлении в БД'
       ) ENGINE = Distributed ('cluster_ch', 'unified_logs', 'logs_local');
