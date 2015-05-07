class CMS.Views.CSS extends Backbone.Marionette.ItemView
  template: "sites/css"

  bindings:
    ".css":
      observe: "css"
      updateModel: false
    "span.title": "title"

  initialize: ->
    @model.whenReady =>
      @collection = @model.sections
      @render()

  onRender: =>
    @stickit()

  setCSS: =>
    # set view value to model

  revertCSS: =>
    # undo changes in view (using value in model)

class CMS.Views.StylerLayout extends Backbone.Marionette.LayoutView
  template: "layouts/styler"

  show: (site_slug) =>
    @model.whenReady =>
      if site_slug and site = @model.sites.findWhere(slug: site_slug)
        site.whenReady =>
          @_css_view = new CMS.Views.CSS
            el: @$el
            model: site
          @_css_view.render()
