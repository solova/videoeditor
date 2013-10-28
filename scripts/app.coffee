requestAnimFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || ((callback) -> window.setTimeout(callback, 1000 / 60))

window.onload = ->
    App = new AppView el:document.body
    App.render()