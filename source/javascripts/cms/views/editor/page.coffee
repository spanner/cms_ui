class CMS.Views.Page extends Backbone.Marionette.CompositeView
  template: "editor/page"
  childView: CMS.Views.Section
  childViewContainer: "main"
  
  childViewOptions: () =>
    toolbar: @_toolbar

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"

  onRender: () =>
    @_site_meta = new CMS.Views.SiteMeta
      model: @model.getSite()
      el: @$el.find("#meta")
    @_site_meta.render()
    @stickit()
