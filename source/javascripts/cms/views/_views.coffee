class CMS.Views.LayoutView extends Backbone.Marionette.LayoutView
  log: (message) =>
    if _cms.logging()
      console.log "#{@constructor.name} view", message


class CMS.Views.MenuLayout extends CMS.Views.LayoutView
  events:
    "click a.title": "openMenu"
  bindings: 
    'a.title': "title"
  

class CMS.Views.ItemView extends Backbone.Marionette.ItemView
  onRender: =>
    @stickit()

  log: (message) =>
    if _cms.logging()
      console.log "#{@constructor.name} view", message


class CMS.Views.CollectionView extends Backbone.Marionette.CollectionView
  @mixin "collection", "toggle"

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

