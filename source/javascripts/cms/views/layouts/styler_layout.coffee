class CMS.Views.CSS extends Backbone.Marionette.ItemView
  template: "sites/css"

  events:
    "click a.preview": "previewCSS"
    "click a.revert": "revertCSS"
    "click a.save": "saveCSS"

  bindings:
    ".temp_css":
      observe: "temp_css"
    "select.template":
      observe: "template"
      selectOptions:
        collection:
          default: "Default"
          spanner: "Spanner"
    "span.title": "title"

    "a.save":
      observe: ["preview_css", "css"]
      visible: (vals) -> vals[0] isnt vals[1]

    "a.preview":
      observe: ["temp_css", "preview_css"]
      visible: (vals) -> vals[0] isnt vals[1]

    "a.revert":
      observe: ["css", "temp_css"]
      visible: (vals) -> vals[0] isnt vals[1]

  onRender: =>
    @stickit()

  setCSS: =>
    # set view value to model

  previewCSS: =>
    @model.previewCSS()

  revertCSS: =>
    @model.revertCSS()

  saveCSS: =>
    @model.save(css:@model.get("preview_css"))

class CMS.Views.StylerLayout extends Backbone.Marionette.LayoutView
  template: "layouts/styler"

  onRender: =>
    @model.whenReady =>
      @_css_view = new CMS.Views.CSS
        el: @$el
        model: @model
      @_css_view.render()
