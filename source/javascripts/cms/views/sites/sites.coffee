class CMS.Views.SiteCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "sites/crumb"

  bindings:
    "span": "title"

class CMS.Views.ListedSite extends Backbone.Marionette.ItemView
  template: "sites/listed"

  bindings:
    "[data-cms='title']":
      observe: "title"
      attributes: [
        observe: "slug"
        name: "href"
        onGet: "url"
      ]

  onRender: =>
    @stickit()

  url: (slug) =>
    "/sites/#{slug}"

class CMS.Views.SitesList extends Backbone.Marionette.CollectionView
  @mixin "collection"
  childView: CMS.Views.ListedSite
