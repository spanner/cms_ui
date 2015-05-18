class CMS.Views.SiteConfig extends Backbone.Marionette.ItemView
  @mixin 'text'
  template: "sites/config"

  bindings:
    ".title": "title"
    ".domain": "domain"

  onRender: =>
    @stickit()
