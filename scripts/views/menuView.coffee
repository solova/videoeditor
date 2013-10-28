class MenuView extends Backbone.View
    tagName: "div"
    className: "pure-menu pure-menu-open pure-menu-horizontal"
    events:
        "change .upload-media": "upload"
        "click .playpause": "playpause"
        "click .fullscreen": "fullscreen"
        "click .save": "save"
        "click .load": "load"
        "click .volumeup": "volumeup"
        "click .volumedown": "volumedown"

    initialize: ->
        @items = [
            className: "playpause"
            caption: "Воспроизведение/Пауза"
        ,
            className: "fullscreen disabled"
            caption: "Полноэкранный режим"
        ,
            className: "volumeup"
            caption: "Громче"
        ,
            className: "volumedown"
            caption: "Тише"
        ,
            className: "save"
            caption: "Сохранить"
        ,
            className: "load"
            caption: "Загрузить"
        ]

    upload: (event) ->
        control = event.target
        files = control.files
        count = files.length
        for file in files
            filename = file.name
            extension = filename.split('.').pop()

            unless extension == "json"
                track = new Track(file)
                TimeLine.add track
            else
                @loadJSON(file)

    playpause: (event) ->
        event.preventDefault()
        state = @model.get("played")
        @model.set "played", !state

    fullscreen: (event) ->
        event.preventDefault()
        state = @model.get("fullscreen")
        @model.set "fullscreen", !state
        false

    save: (event) ->
        json = JSON.stringify @model.get("tracks").toJSON()
        blob = new Blob [json], type: "application/json"
        url  = URL.createObjectURL blob

        link = document.querySelector(".save")
        link.download = "project.json"
        link.href = url

    load: (event) ->
        event.preventDefault()
        alert "Загрузите json-файл проекта в первом пункте меню (как медиафрагмент)"

    loadJSON: (file) ->
        fileReader = new FileReader()
        fileReader.onload = (event) =>
            result = JSON.parse(event.target.result)
            @model.get("tracks").reset(result)

        fileReader.readAsText file

    volumeup: (event) ->
        event.preventDefault()
        volume = @model.get "volume"
        volume = Math.min volume + 0.1, 1
        @model.set "volume", volume

    volumedown: (event) ->
        event.preventDefault()
        volume = @model.get "volume"
        volume = Math.max volume - 0.1, 0
        @model.set "volume", volume

    template: (item) ->
        """<li><a href="#" class="#{item.className}">#{item.caption}</a></li>"""

    render: ->

        header = document.createElement "B"
        header.className = "pure-menu-heading"
        header.innerHTML = "Загрузка файлов:"

        menu = document.createElement "ul"
        menu.innerHTML = (@items.map @template).join('')

        upload = document.createElement "INPUT"
        upload.setAttribute "type", "file"
        upload.setAttribute "multiple", "multiple"
        upload.setAttribute "accept", "image/*|audio/*"
        upload.className = "upload-media"

        @el.appendChild header
        @el.appendChild upload
        @el.appendChild menu

        @