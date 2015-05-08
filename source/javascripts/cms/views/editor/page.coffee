class CMS.Views.Page extends Backbone.Marionette.CompositeView
  template: "editor/page"
  childView: CMS.Views.Section
  childViewContainer: "main"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"

  onRender: () =>
    @stickit()

