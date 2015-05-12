class CMS.Views.SiteConfig extends Backbone.Marionette.ItemView
  template: "sites/config"

  onRender: =>
    @stickit()
