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