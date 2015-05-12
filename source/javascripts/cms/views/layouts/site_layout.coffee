class CMS.Views.CSS extends Backbone.Marionette.ItemView
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

  paste: (e) ->
    e.preventDefault()
    document.execCommand("insertHTML", false, e.originalEvent.clipboardData.getData("text/plain"))

  setCSS: =>
    # set view value to model

  previewCSS: =>
    @model.previewCSS()

  revertCSS: =>
    @model.revertCSS()

  saveCSS: =>
    @model.save(css:@model.get("preview_css"))

class CMS.Views.SiteEditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/site_editor"

  events:
    "click nav a": "showTab"

  bindings:
    "span.title": "title"

  onRender: =>
    @stickit()
    @model.whenReady =>
      @_css_view = new CMS.Views.CSS
        el: @$el.find("#style")
        model: @model
      @_css_view.render()

  showTab: (e) =>
    el = $(e.currentTarget)
    tab = el.attr("class")
    unless el.hasClass("current")
      @$el.find(".current").removeClass("current")
      @$el.find(".#{tab},##{tab}").addClass("current")
