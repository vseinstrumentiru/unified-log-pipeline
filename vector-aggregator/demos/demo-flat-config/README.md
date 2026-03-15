# Vector demo-flat-config

В данной папке пример конфигурации, когда комопненты описываются в отдельных файлах, имя файла любое. Тип компонента и настройки целиком заданы в конфигурации.

Базовые настройки в `vector.toml` (включение API).

Компонеты это: source, sink, transforms.

Например, копмонент `sinks.console` лежит в файле sink_console.toml:

        [sinks.console]
        type = "console"
        inputs = ["simple_remap"]

        [sinks.console.encoding]
        codec = "json"

Но вы можете назвать его как угодно сохранив расширение .toml - он все равно будет считан и использован.

Имена файлов тут на ваш выбор.
