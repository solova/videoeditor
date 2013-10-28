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
