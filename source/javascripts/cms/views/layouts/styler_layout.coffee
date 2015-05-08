class CMS.Views.CSS extends Backbone.Marionette.ItemView
  template: "sites/css"

  bindings:
    ".css":
      observe: "css"
      # updateModel: false
    "span.title": "title"

  onRender: =>
    @model.on "change:css", (model, val) =>
      _cms.setCSS val
    @stickit()

  setCSS: =>
    # set view value to model

  revertCSS: =>
    # undo changes in view (using value in model)

class CMS.Views.StylerLayout extends Backbone.Marionette.LayoutView
  template: "layouts/styler"

  onRender: =>
    @model.whenReady =>
      @_css_view = new CMS.Views.CSS
        el: @$el
        model: @model
      @_css_view.render()
