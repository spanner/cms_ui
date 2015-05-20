class CMS.Views.SiteAssets extends Backbone.Marionette.ItemView
  template: "sites/assets"

  onRender: (e) =>
    _.delay @show, 2

  show: =>
