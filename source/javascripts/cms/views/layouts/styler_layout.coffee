class CMS.Views.CSS extends Backbone.Marionette.ItemView
  template: "sites/css"

  events:
    "click a.preview": "preview"
    "click a.revert": "revert"
    "click a.save": "save"

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
      observe: ["temp_css", "css"]
      visible: (vals) -> vals[0] is vals[1]

    "a.preview":
      observe: ["temp_css", "css"]
      visible: (vals) -> vals[0] isnt vals[1]

    "a.revert":
      observe: ["old_css", "css", "temp_css"]
      visible: (vals) -> vals[0] isnt (vals[1] or vals[2])

  onRender: =>
    @stickit()

  setCSS: =>
    # set view value to model

  preview: =>
    @model.applyCSS()

  revert: =>
    @model.revertCSS()

  save: =>
    @model.save()
  

class CMS.Views.StylerLayout extends Backbone.Marionette.LayoutView
  template: "layouts/styler"

  onRender: =>
    @model.whenReady =>
      @_css_view = new CMS.Views.CSS
        el: @$el
        model: @model
      @_css_view.render()
