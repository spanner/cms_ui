class CMS.Views.CSS extends Backbone.Marionette.ItemView
  @mixin 'text'
  template: "sites/css"

  events:
    "click a.preview": "previewCSS"
    "click a.revert": "revertCSS"
    "click a.save": "saveCSS"
    "paste .temp_css": "paste"

  bindings:
    ".temp_css": "temp_css"
    "select.template":
      observe: "template"
      selectOptions:
        collection:
          default: "Default"
          spanner: "Spanner"
    "a.save":
      observe: ["temp_css","preview_css", "css"]
      visible: (vals) -> vals[0] is vals[1] and vals[0] isnt vals[2]
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