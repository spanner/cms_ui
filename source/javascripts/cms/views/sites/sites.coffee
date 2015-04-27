class CMS.Views.SiteCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "sites/crumb"

  events:
    "click": "onClick"

  bindings:
    "span": "title"

  onClick: =>
    

class CMS.Views.ListedSite extends Backbone.Marionette.ItemView
  template: "sites/listed"

  bindings:
    ".cms-title":
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
