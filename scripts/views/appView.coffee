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