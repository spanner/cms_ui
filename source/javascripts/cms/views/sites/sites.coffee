class CMS.Views.SiteCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "sites/crumb"

  events:
    "click": "onClick"

  bindings:
    "span": "title"

  onClick: =>
    _cms.vent.trigger "toggle_list", "_sites_list"

class CMS.Views.ListedSite extends Backbone.Marionette.ItemView
  template: "sites/listed"

  events:
    "click": "onClick"

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

  onClick: =>
    _cms.vent.trigger "hide_list", "_sites_list"

class CMS.Views.SitesList extends Backbone.Marionette.CollectionView
  @mixin "collection", "toggle"
  childView: CMS.Views.ListedSite

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()
