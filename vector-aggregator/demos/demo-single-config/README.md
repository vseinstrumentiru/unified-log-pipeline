# Vector demo-single-config

В данной папке пример конфигурации, когда все комопненты описываются прямо в одном файле `vector.toml`.

Компонеты это: source, sink, transforms.

Все компоненты имеют полные имена прямо в файле, пример одного:

        [sinks.console]
        type = "console"
        inputs = ["simple_remap"]

        [sinks.console.encoding]
        codec = "json"

Пример полный в `./vector-aggregator.toml`
