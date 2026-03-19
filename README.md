# Ви.Tech Unified Log Pipeline

[Ви.Tech](https://vitech.team) - команда инженеров которая строит ИТ для http://vi.ru

Реализация стандарта логирования на базе [OpenTelemetry Logs Data Model](https://opentelemetry.io/docs/specs/otel/logs/data-model/).
Мы адаптировали для себя OpenTelemetry Logs Data Model, что возволило нам стандартизировать работу с логами. Это существенно облегчило эксплуатацию системы сбора логов DevOps/SRE команде, высвободило большое количество инженерного времени.
Вместо 5 часов на подключение одного источника логов, теперь мы тратим 5-10 минут - проверить что логи поступают.

Реализовано при помощи: vector.dev, Ansible playbook, ClickHouse, Redash (или HyperDX из ClickStack).

В данном репозитории предложены:
* Шаблоны кода компонентов пайплана vector.dev
* Makefile для управления задачами
* Ansible playbook генерации конфигурации vector.dev из шаблонов
* Схема данных CickHouse
* Демо работы системы на основе Deocker-compose для локального изучения

По мере обнаружения багов или добавленя функционала мы будем выкладывать сюда обновления.

> **ВАЖНО! Сайты vector.dev могут частично попадать в блокировку РКН, потому чтобы установщик мог скачать образы, нужно включить VPN.**  
> Если нужно, то можем собрать готовый образ и положить сюда - заведите [Issue](https://github.com/vseinstrumentiru/unified-log-pipeline/issues) если это действительно вам нужно. 


## История создания

Читайте в статьях:
* [Как ELK довел нас… до Vector.dev и Clickhouse](https://habr.com/ru/companies/vitech/articles/808313/) (Habr, 2024)
* [Vector.dev: как упростить подсчет метрик по логам](https://habr.com/ru/companies/vitech/articles/809801/) (Habr, 2024)
* [Практики SRE: стандартизация логов](https://habr.com/ru/companies/vitech/articles/854424/) (Habr, 2024)

Доклады:
* [Как ELK довел нас… до Vector.dev и Clickhouse](https://devopsconf.io/moscow/2024/abstracts/11564) (2024, DevOpsConf). [Видео YouTube](https://youtu.be/4Xu-DaGkldU)
* [Укрощение хаоса логов с помощью модели OpenTelemetry, Vector и ClickHouse. Итоги за два года](https://devopsconf.io/moscow/2025/abstracts/14184) (2025, DevOpsConf). [Видео VK Video](https://vkvideo.ru/video-163333847_456239934?list=ln-Zu57y3zqrzJjmSTHjn)
