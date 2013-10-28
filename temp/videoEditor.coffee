class Track extends Backbone.Model
    defaults:
        offset: 0
        duration: 5000
        resizable: no
        visible: no

    initialize: (source) ->
        if source?
            fileReader = new FileReader()
            fileReader.onload = (event) =>
                @.set "name", source.name
                @.set "size", source.size
                @.set "type", source.type
                @.set "data", event.target.result

                if source.type == "audio/mp3"
                    @.set "mp3", new Audio(event.target.result)

            fileReader.readAsDataURL(source)

    offset: (timeInSeconds) ->
        if timeInSeconds?
            @.set "offset", timeInSeconds * 1000.0
        else
            (@.get "offset") / 1000.0

    duration: (timeInSeconds) ->
        if timeInSeconds?
            @.set "duration", timeInSeconds * 1000.0
        else
            (@.get "duration") / 1000.0
class Tracks extends Backbone.Collection
    model: Track
class TimeLineInstance extends Backbone.Model
    defaults:
        volume: 0.5
        position: 0
        len: 10
        fullscreen: no
        played: no

    initialize: ->
        tracks = new Tracks()
        tracks.on "change", =>
            max = 0
            tracks.forEach (track) =>
                upperBound = track.offset()+track.duration()
                max = upperBound if upperBound > max
            if @.get("len") < max
                @.set "len", max
        @.set "tracks", tracks

        @next()
    add: (track) ->
        tracks = @.get "tracks"
        tracks.add track
        track
    remove: (track) ->
        tracks = @.get "tracks"
        tracks.remove track
        track

    next: ->
        if @.get("played") == yes
            if @lastFrame != 0
                timeOffset = +(new Date()) - @lastFrame
                position = @.get "position"
                position += timeOffset/1000.0
                position = 0 if position > @.get("len")
                @.set "position", position + timeOffset/1000.0
            @lastFrame = +(new Date())
        else
            @lastFrame = 0
        webkitRequestAnimationFrame (=> @next())

    play: ->
        @.set "played", yes
    pause: ->
        @.set "played", no

    volume: (level) ->
        if level?
            @.set "volume", level
        else
            @.get "volume"
    position: (timeInSeconds) ->
        if timeInSeconds?
            @.set "position", timeInSeconds
        else
            @.get "position"
    tracks: ->
        (@.get "tracks").models

TimeLine = new TimeLineInstance()
class AppView extends Backbone.View

    render: ->
        menu = new MenuView model:TimeLine
        menu.render()

        preview = new PreviewView model:TimeLine
        preview.render()

        progress = new ProgressView model: TimeLine
        progress.render()

        timeline = new TimelineView model:TimeLine
        timeline.render()

        @el.removeChild @el.firstChild while @el.firstChild #empty exists

        @el.appendChild menu.el
        @el.appendChild preview.el
        @el.appendChild progress.el
        @el.appendChild timeline.el
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
class PreviewView extends Backbone.View
    tagName: "div"
    className: "video"
    initialize: ->

        @status = document.createElement "div"
        @status.className = "status"
        @el.appendChild @status

        @imageContainer = document.createElement "div"
        @imageContainer.className = "imageContainer"
        @el.appendChild @imageContainer

        activeCollection = Backbone.Collection.extend( model:Track )

        @active = new activeCollection()
        @active.on "add", @addMedia, @
        @active.on "remove", @removeMedia, @

        @model.on "change:played change:position change:volume", @render, @
        @model.on "change:volume", @changeVolume, @

    addMedia: (model) ->
        if model.get("type") in ['image/jpeg','image/png']
            data = model.get "data"
            @imageContainer.style.backgroundImage = """url(#{data})"""

        if model.get("type") == "audio/mp3"
            model.get("mp3").volume = @model.get "volume"
            model.get("mp3").currentTime = @model.get("position") - model.get("offset")
            model.get("mp3").play()
    removeMedia: (model) ->
        if model.get("type") in ['image/jpeg','image/png']
            data = ""
            @active.forEach (model) ->
                if model.get("type") in ['image/jpeg','image/png']
                    data = model.get "data"
            if data
                @imageContainer.style.backgroundImage = """url(#{data})"""
            else
                @imageContainer.style.backgroundImage = """none"""
        else
            model.get("mp3").pause()

    changeVolume: ->
        volume = @model.get "volume"
        tracks = @model.get "tracks"
        tracks.forEach (track) =>
            if track.get("type") == "audio/mp3"
                track.get("mp3").volume = volume

    render: ->
        volume = Math.floor (100 * @model.get "volume")
        position = @model.get "position"
        played = @model.get "played"
        state = if played then "Играется" else "На паузе"
        @status.innerHTML = """#{state} Громкость: #{volume}"""

        tracks = @model.get "tracks"

        tracks.forEach (track) =>
            if position >= track.offset() and position < track.offset() + track.duration()
                if track.get("visible") == off
                    track.set "visible", on
                    @active.add track
            else
                if track.get("visible") == on
                    track.set "visible", off
                    @active.remove track

        @

class ProgressView extends Backbone.View
    tagName: "div"
    className: "progress"
    events:
        "click": "goto"
    initialize: ->
        @indicator = document.createElement "b"
        @indicator.className = "indicator"
        @el.appendChild @indicator

        @model.on "change:position", @render, @
    goto: (event) ->

        @model.set "position", event.clientX/100.0

    render: ->
        @indicator.style.width = @model.get("position")*100 + "px"
class TimelineView extends Backbone.View
    tagName: "ul"
    className: "timeline"
    events:
        "mousedown .element span": "dragstart"
        "mouseup": "dragend"
        "mousemove": "drag"
    initialize: ->
        @collection = @model.get("tracks")
        @collection.on "add remove reset", @render, @

    dragstart: (event) ->

        @dragEl = event.delegateTarget

        if event.target.tagName.toLowerCase() == "b"
            @dragEl.classList.add "draggable"
        else
            @dragEl.classList.add "resizable"
        @dragX = event.clientX
        @dragW = parseInt(@dragEl.firstChild.style.width, 10)

    drag: (event) ->
        if @dragEl?
            if @dragEl.classList.contains "draggable"
                offset = @dragEl.dataset.offset | 0
                offset += event.clientX - @dragX
                @dragEl.style.left = "#{offset}px"
            if @dragEl.classList.contains "resizable"
                offset = event.clientX - @dragX
                width = @dragW + offset
                @dragEl.firstChild.style.width = """#{width}px"""
    dragend: (event) ->
        if @dragEl?
            if @dragEl.classList.contains "draggable"
                @dragEl.classList.remove "draggable"

                offset = @dragEl.dataset.offset | 0
                offset += event.clientX - @dragX

                @dragEl.style.left = "#{offset}px"
                @dragEl.dataset.offset = offset

                cid = @dragEl.dataset.cid
                @collection.get(cid).set "offset", offset*10

            if @dragEl.classList.contains "resizable"
                @dragEl.classList.remove "resizable"
                offset = event.clientX - @dragX
                width = @dragW + offset
                cid = @dragEl.dataset.cid
                @collection.get(cid).set "duration", width*10
            @dragEl = null


    template: (item) ->
        width = item.get("duration") / 10
        offset = item.get("offset") / 10
        """<li class="element"><span data-cid="#{item.cid}" style="left: #{offset}px" data-offset="#{offset}"><b style="width:#{width}px">#{item.get("name")} (#{item.get("type")})</b><span></li>"""
    render: ->
        @el.innerHTML = (@collection.map @template, @).join('')
        @

requestAnimFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || ((callback) -> window.setTimeout(callback, 1000 / 60))

window.onload = ->
    App = new AppView el:document.body
    App.render()