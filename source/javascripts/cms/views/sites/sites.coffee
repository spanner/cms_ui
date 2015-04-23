class CMS.Views.SiteCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "sites/crumb"

  bindings:
    "[data-cms='title']": "title"

class CMS.Views.ListedSite extends Backbone.Marionette.ItemView
  template: "sites/listed"

  bindings:
    "[data-cms='name']":
      observe: "name"
      attributes: [
        observe: "uid"
        name: "href"
        onGet: "url"
      ]

  onRender: =>
    @stickit()

class CMS.Views.SitesList extends Backbone.Marionette.CollectionView
  childView: CMS.Views.ListedSite
