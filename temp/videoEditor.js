(function() {
  var AppView, MenuView, PreviewView, ProgressView, TimeLine, TimeLineInstance, TimelineView, Track, Tracks, requestAnimFrame, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Track = (function(_super) {
    __extends(Track, _super);

    function Track() {
      _ref = Track.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Track.prototype.defaults = {
      offset: 0,
      duration: 5000,
      resizable: false,
      visible: false
    };

    Track.prototype.initialize = function(source) {
      var fileReader,
        _this = this;
      if (source != null) {
        fileReader = new FileReader();
        fileReader.onload = function(event) {
          _this.set("name", source.name);
          _this.set("size", source.size);
          _this.set("type", source.type);
          _this.set("data", event.target.result);
          if (source.type === "audio/mp3") {
            return _this.set("mp3", new Audio(event.target.result));
          }
        };
        return fileReader.readAsDataURL(source);
      }
    };

    Track.prototype.offset = function(timeInSeconds) {
      if (timeInSeconds != null) {
        return this.set("offset", timeInSeconds * 1000.0);
      } else {
        return (this.get("offset")) / 1000.0;
      }
    };

    Track.prototype.duration = function(timeInSeconds) {
      if (timeInSeconds != null) {
        return this.set("duration", timeInSeconds * 1000.0);
      } else {
        return (this.get("duration")) / 1000.0;
      }
    };

    return Track;

  })(Backbone.Model);

  Tracks = (function(_super) {
    __extends(Tracks, _super);

    function Tracks() {
      _ref1 = Tracks.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Tracks.prototype.model = Track;

    return Tracks;

  })(Backbone.Collection);

  TimeLineInstance = (function(_super) {
    __extends(TimeLineInstance, _super);

    function TimeLineInstance() {
      _ref2 = TimeLineInstance.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    TimeLineInstance.prototype.defaults = {
      volume: 0.5,
      position: 0,
      len: 10,
      fullscreen: false,
      played: false
    };

    TimeLineInstance.prototype.initialize = function() {
      var tracks,
        _this = this;
      tracks = new Tracks();
      tracks.on("change", function() {
        var max;
        max = 0;
        tracks.forEach(function(track) {
          var upperBound;
          upperBound = track.offset() + track.duration();
          if (upperBound > max) {
            return max = upperBound;
          }
        });
        if (_this.get("len") < max) {
          return _this.set("len", max);
        }
      });
      this.set("tracks", tracks);
      return this.next();
    };

    TimeLineInstance.prototype.add = function(track) {
      var tracks;
      tracks = this.get("tracks");
      tracks.add(track);
      return track;
    };

    TimeLineInstance.prototype.remove = function(track) {
      var tracks;
      tracks = this.get("tracks");
      tracks.remove(track);
      return track;
    };

    TimeLineInstance.prototype.next = function() {
      var position, timeOffset,
        _this = this;
      if (this.get("played") === true) {
        if (this.lastFrame !== 0) {
          timeOffset = +(new Date()) - this.lastFrame;
          position = this.get("position");
          position += timeOffset / 1000.0;
          if (position > this.get("len")) {
            position = 0;
          }
          this.set("position", position + timeOffset / 1000.0);
        }
        this.lastFrame = +(new Date());
      } else {
        this.lastFrame = 0;
      }
      return webkitRequestAnimationFrame((function() {
        return _this.next();
      }));
    };

    TimeLineInstance.prototype.play = function() {
      return this.set("played", true);
    };

    TimeLineInstance.prototype.pause = function() {
      return this.set("played", false);
    };

    TimeLineInstance.prototype.volume = function(level) {
      if (level != null) {
        return this.set("volume", level);
      } else {
        return this.get("volume");
      }
    };

    TimeLineInstance.prototype.position = function(timeInSeconds) {
      if (timeInSeconds != null) {
        return this.set("position", timeInSeconds);
      } else {
        return this.get("position");
      }
    };

    TimeLineInstance.prototype.tracks = function() {
      return (this.get("tracks")).models;
    };

    return TimeLineInstance;

  })(Backbone.Model);

  TimeLine = new TimeLineInstance();

  AppView = (function(_super) {
    __extends(AppView, _super);

    function AppView() {
      _ref3 = AppView.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    AppView.prototype.render = function() {
      var menu, preview, progress, timeline;
      menu = new MenuView({
        model: TimeLine
      });
      menu.render();
      preview = new PreviewView({
        model: TimeLine
      });
      preview.render();
      progress = new ProgressView({
        model: TimeLine
      });
      progress.render();
      timeline = new TimelineView({
        model: TimeLine
      });
      timeline.render();
      while (this.el.firstChild) {
        this.el.removeChild(this.el.firstChild);
      }
      this.el.appendChild(menu.el);
      this.el.appendChild(preview.el);
      this.el.appendChild(progress.el);
      return this.el.appendChild(timeline.el);
    };

    return AppView;

  })(Backbone.View);

  MenuView = (function(_super) {
    __extends(MenuView, _super);

    function MenuView() {
      _ref4 = MenuView.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    MenuView.prototype.tagName = "div";

    MenuView.prototype.className = "pure-menu pure-menu-open pure-menu-horizontal";

    MenuView.prototype.events = {
      "change .upload-media": "upload",
      "click .playpause": "playpause",
      "click .fullscreen": "fullscreen",
      "click .save": "save",
      "click .load": "load",
      "click .volumeup": "volumeup",
      "click .volumedown": "volumedown"
    };

    MenuView.prototype.initialize = function() {
      return this.items = [
        {
          className: "playpause",
          caption: "Воспроизведение/Пауза"
        }, {
          className: "fullscreen disabled",
          caption: "Полноэкранный режим"
        }, {
          className: "volumeup",
          caption: "Громче"
        }, {
          className: "volumedown",
          caption: "Тише"
        }, {
          className: "save",
          caption: "Сохранить"
        }, {
          className: "load",
          caption: "Загрузить"
        }
      ];
    };

    MenuView.prototype.upload = function(event) {
      var control, count, extension, file, filename, files, track, _i, _len, _results;
      control = event.target;
      files = control.files;
      count = files.length;
      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        filename = file.name;
        extension = filename.split('.').pop();
        if (extension !== "json") {
          track = new Track(file);
          _results.push(TimeLine.add(track));
        } else {
          _results.push(this.loadJSON(file));
        }
      }
      return _results;
    };

    MenuView.prototype.playpause = function(event) {
      var state;
      event.preventDefault();
      state = this.model.get("played");
      return this.model.set("played", !state);
    };

    MenuView.prototype.fullscreen = function(event) {
      var state;
      event.preventDefault();
      state = this.model.get("fullscreen");
      this.model.set("fullscreen", !state);
      return false;
    };

    MenuView.prototype.save = function(event) {
      var blob, json, link, url;
      json = JSON.stringify(this.model.get("tracks").toJSON());
      blob = new Blob([json], {
        type: "application/json"
      });
      url = URL.createObjectURL(blob);
      link = document.querySelector(".save");
      link.download = "project.json";
      return link.href = url;
    };

    MenuView.prototype.load = function(event) {
      event.preventDefault();
      return alert("Загрузите json-файл проекта в первом пункте меню (как медиафрагмент)");
    };

    MenuView.prototype.loadJSON = function(file) {
      var fileReader,
        _this = this;
      fileReader = new FileReader();
      fileReader.onload = function(event) {
        var result;
        result = JSON.parse(event.target.result);
        return _this.model.get("tracks").reset(result);
      };
      return fileReader.readAsText(file);
    };

    MenuView.prototype.volumeup = function(event) {
      var volume;
      event.preventDefault();
      volume = this.model.get("volume");
      volume = Math.min(volume + 0.1, 1);
      return this.model.set("volume", volume);
    };

    MenuView.prototype.volumedown = function(event) {
      var volume;
      event.preventDefault();
      volume = this.model.get("volume");
      volume = Math.max(volume - 0.1, 0);
      return this.model.set("volume", volume);
    };

    MenuView.prototype.template = function(item) {
      return "<li><a href=\"#\" class=\"" + item.className + "\">" + item.caption + "</a></li>";
    };

    MenuView.prototype.render = function() {
      var header, menu, upload;
      header = document.createElement("B");
      header.className = "pure-menu-heading";
      header.innerHTML = "Загрузка файлов:";
      menu = document.createElement("ul");
      menu.innerHTML = (this.items.map(this.template)).join('');
      upload = document.createElement("INPUT");
      upload.setAttribute("type", "file");
      upload.setAttribute("multiple", "multiple");
      upload.setAttribute("accept", "image/*|audio/*");
      upload.className = "upload-media";
      this.el.appendChild(header);
      this.el.appendChild(upload);
      this.el.appendChild(menu);
      return this;
    };

    return MenuView;

  })(Backbone.View);

  PreviewView = (function(_super) {
    __extends(PreviewView, _super);

    function PreviewView() {
      _ref5 = PreviewView.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    PreviewView.prototype.tagName = "div";

    PreviewView.prototype.className = "video";

    PreviewView.prototype.initialize = function() {
      var activeCollection;
      this.status = document.createElement("div");
      this.status.className = "status";
      this.el.appendChild(this.status);
      this.imageContainer = document.createElement("div");
      this.imageContainer.className = "imageContainer";
      this.el.appendChild(this.imageContainer);
      activeCollection = Backbone.Collection.extend({
        model: Track
      });
      this.active = new activeCollection();
      this.active.on("add", this.addMedia, this);
      this.active.on("remove", this.removeMedia, this);
      this.model.on("change:played change:position change:volume", this.render, this);
      return this.model.on("change:volume", this.changeVolume, this);
    };

    PreviewView.prototype.addMedia = function(model) {
      var data, _ref6;
      if ((_ref6 = model.get("type")) === 'image/jpeg' || _ref6 === 'image/png') {
        data = model.get("data");
        this.imageContainer.style.backgroundImage = "url(" + data + ")";
      }
      if (model.get("type") === "audio/mp3") {
        model.get("mp3").volume = this.model.get("volume");
        model.get("mp3").currentTime = this.model.get("position") - model.get("offset");
        return model.get("mp3").play();
      }
    };

    PreviewView.prototype.removeMedia = function(model) {
      var data, _ref6;
      if ((_ref6 = model.get("type")) === 'image/jpeg' || _ref6 === 'image/png') {
        data = "";
        this.active.forEach(function(model) {
          var _ref7;
          if ((_ref7 = model.get("type")) === 'image/jpeg' || _ref7 === 'image/png') {
            return data = model.get("data");
          }
        });
        if (data) {
          return this.imageContainer.style.backgroundImage = "url(" + data + ")";
        } else {
          return this.imageContainer.style.backgroundImage = "none";
        }
      } else {
        return model.get("mp3").pause();
      }
    };

    PreviewView.prototype.changeVolume = function() {
      var tracks, volume,
        _this = this;
      volume = this.model.get("volume");
      tracks = this.model.get("tracks");
      return tracks.forEach(function(track) {
        if (track.get("type") === "audio/mp3") {
          return track.get("mp3").volume = volume;
        }
      });
    };

    PreviewView.prototype.render = function() {
      var played, position, state, tracks, volume,
        _this = this;
      volume = Math.floor(100 * this.model.get("volume"));
      position = this.model.get("position");
      played = this.model.get("played");
      state = played ? "Играется" : "На паузе";
      this.status.innerHTML = "" + state + " Громкость: " + volume;
      tracks = this.model.get("tracks");
      tracks.forEach(function(track) {
        if (position >= track.offset() && position < track.offset() + track.duration()) {
          if (track.get("visible") === false) {
            track.set("visible", true);
            return _this.active.add(track);
          }
        } else {
          if (track.get("visible") === true) {
            track.set("visible", false);
            return _this.active.remove(track);
          }
        }
      });
      return this;
    };

    return PreviewView;

  })(Backbone.View);

  ProgressView = (function(_super) {
    __extends(ProgressView, _super);

    function ProgressView() {
      _ref6 = ProgressView.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    ProgressView.prototype.tagName = "div";

    ProgressView.prototype.className = "progress";

    ProgressView.prototype.events = {
      "click": "goto"
    };

    ProgressView.prototype.initialize = function() {
      this.indicator = document.createElement("b");
      this.indicator.className = "indicator";
      this.el.appendChild(this.indicator);
      return this.model.on("change:position", this.render, this);
    };

    ProgressView.prototype.goto = function(event) {
      return this.model.set("position", event.clientX / 100.0);
    };

    ProgressView.prototype.render = function() {
      return this.indicator.style.width = this.model.get("position") * 100 + "px";
    };

    return ProgressView;

  })(Backbone.View);

  TimelineView = (function(_super) {
    __extends(TimelineView, _super);

    function TimelineView() {
      _ref7 = TimelineView.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    TimelineView.prototype.tagName = "ul";

    TimelineView.prototype.className = "timeline";

    TimelineView.prototype.events = {
      "mousedown .element span": "dragstart",
      "mouseup": "dragend",
      "mousemove": "drag"
    };

    TimelineView.prototype.initialize = function() {
      this.collection = this.model.get("tracks");
      return this.collection.on("add remove reset", this.render, this);
    };

    TimelineView.prototype.dragstart = function(event) {
      this.dragEl = event.delegateTarget;
      if (event.target.tagName.toLowerCase() === "b") {
        this.dragEl.classList.add("draggable");
      } else {
        this.dragEl.classList.add("resizable");
      }
      this.dragX = event.clientX;
      return this.dragW = parseInt(this.dragEl.firstChild.style.width, 10);
    };

    TimelineView.prototype.drag = function(event) {
      var offset, width;
      if (this.dragEl != null) {
        if (this.dragEl.classList.contains("draggable")) {
          offset = this.dragEl.dataset.offset | 0;
          offset += event.clientX - this.dragX;
          this.dragEl.style.left = "" + offset + "px";
        }
        if (this.dragEl.classList.contains("resizable")) {
          offset = event.clientX - this.dragX;
          width = this.dragW + offset;
          return this.dragEl.firstChild.style.width = "" + width + "px";
        }
      }
    };

    TimelineView.prototype.dragend = function(event) {
      var cid, offset, width;
      if (this.dragEl != null) {
        if (this.dragEl.classList.contains("draggable")) {
          this.dragEl.classList.remove("draggable");
          offset = this.dragEl.dataset.offset | 0;
          offset += event.clientX - this.dragX;
          this.dragEl.style.left = "" + offset + "px";
          this.dragEl.dataset.offset = offset;
          cid = this.dragEl.dataset.cid;
          this.collection.get(cid).set("offset", offset * 10);
        }
        if (this.dragEl.classList.contains("resizable")) {
          this.dragEl.classList.remove("resizable");
          offset = event.clientX - this.dragX;
          width = this.dragW + offset;
          cid = this.dragEl.dataset.cid;
          this.collection.get(cid).set("duration", width * 10);
        }
        return this.dragEl = null;
      }
    };

    TimelineView.prototype.template = function(item) {
      var offset, width;
      width = item.get("duration") / 10;
      offset = item.get("offset") / 10;
      return "<li class=\"element\"><span data-cid=\"" + item.cid + "\" style=\"left: " + offset + "px\" data-offset=\"" + offset + "\"><b style=\"width:" + width + "px\">" + (item.get("name")) + " (" + (item.get("type")) + ")</b><span></li>";
    };

    TimelineView.prototype.render = function() {
      this.el.innerHTML = (this.collection.map(this.template, this)).join('');
      return this;
    };

    return TimelineView;

  })(Backbone.View);

  requestAnimFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || (function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  });

  window.onload = function() {
    var App;
    App = new AppView({
      el: document.body
    });
    return App.render();
  };

}).call(this);
