class CMS.Views.SiteConfig extends Backbone.Marionette.ItemView
  template: "sites/config"

  bindings:
    ".title": "title"
    ".domain": "domain"

  onRender: =>
    @stickit()
