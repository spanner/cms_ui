class CMS.Views.SiteHtml extends Backbone.Marionette.ItemView
  template: "sites/html"

  onRender: (e) =>
    _.delay @show, 2

  show: =>
    #...