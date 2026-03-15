# Vector demo с autonamespaced config

В данной папке пример конфигурации с авторазбиением на пространства по типу компонента. Под каждый тип компонентов свои папки: sources, transforms, sinks. И также есть общий файл с базовыми настройкми vector (например, включение API).

При таком шаблоне конфигурации имя файла принимается за имя компонента. Vector автомтически присвоит нужные имена компонентам (добавит)

Важно! В файле должен отсутствовать заголовок с указанием типа, например, `[sink.my_sink]`, также вложенные свойства должны именоваться без префикса. Вместо:

        [sinks.console]
        type = "console"
        inputs = ["simple_remap"]

        [sinks.console.encoding]
        codec = "json"

Получается файл `sinks/console.toml` с содержимым

        type = "console"
        inputs = ["simple_remap"]

        [encoding]
        codec = "json"
