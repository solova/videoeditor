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

        window.requestAnimationFrame ||= window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame

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

        window.requestAnimationFrame (=> @next())

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