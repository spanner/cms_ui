class CMS.Views.LayoutView extends Backbone.Marionette.LayoutView
  log: () =>
    if _cms.logging()
      console.log "#{@constructor.name} view", arguments...


class CMS.Views.MenuLayout extends CMS.Views.LayoutView
  events:
    "click a.title": "openMenu"
  bindings: 
    '.header a.title': "title"
  

class CMS.Views.ItemView extends Backbone.Marionette.ItemView
  onRender: =>
    @stickit()

  log: () =>
    if _cms.logging()
      console.log "#{@constructor.name} view", arguments...


class CMS.Views.CollectionView extends Backbone.Marionette.CollectionView
  @mixin "collection", "toggle"

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

