class CMS.Views.Page extends Backbone.Marionette.CompositeView
  template: "editor/page"
  childView: CMS.Views.Section
  childViewContainer: "main"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"

  onRender: () =>
    @_site_styles = new CMS.Views.SiteStyles
      model: @model.getSite()
      el: @$el.find("#styles")
    @_site_styles.render()
    @stickit()
