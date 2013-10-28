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
