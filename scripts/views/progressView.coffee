class ProgressView extends Backbone.View
    tagName: "div"
    className: "progress"
    events:
        "click .indicator": "goto"
    initialize: ->
        @indicator = document.createElement "b"
        @indicator.className = "indicator"
        @el.appendChild @indicator

        @model.on "change:position", @render, @
    goto: (event) ->
        @model.set "position", event.clientX/100.0

    render: ->
        @indicator.style.width = @model.get("position")*100 + "px"