class CMS.Views.LayoutView extends Backbone.Marionette.LayoutView
  log: () =>
    if _cms.logging()
      console.log "#{@constructor.name} view", arguments...


class CMS.Views.MenuLayout extends CMS.Views.LayoutView
  events:
    "click > .header a.title": "toggleMenu"

  bindings: 
    '.header a.title': "title"


class CMS.Views.CollectionView extends Backbone.Marionette.CollectionView
  @mixin "collection", "toggle"

  show: () =>
    @$el.show()
  
  hide: () =>
    @$el.hide()


class CMS.Views.MenuView extends CMS.Views.CollectionView

  show: =>
    @$el.slideDown
      duration: 400
      easing: "boing"

  hide: =>
    @$el.slideUp
      duration: 400
      easing: "glide"


class CMS.Views.ItemView extends Backbone.Marionette.ItemView
  onRender: =>
    @stickit()

  log: () =>
    if _cms.logging()
      console.log "#{@constructor.name} view", arguments...


