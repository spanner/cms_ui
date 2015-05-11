class CMS.Views.LayoutView extends Backbone.Marionette.LayoutView
  @mixin "logging"


class CMS.Views.MenuLayout extends CMS.Views.LayoutView
  events:
    "click > .header a.title": "toggleMenu"

  bindings:
    '.header a.title':
      observe: "title"
      updateMethod: "html"

  initialize: ->
    super
    _cms.vent.on "reset", @close

  onRender: =>
    if menu_view_class = @getOption('menuView')
      @_menu_view = new menu_view_class
        el: @$el.find(".menu")
        collection: @collection
      @_menu_view.render()

  toggleMenu: =>
    if @_menu_view.showing()
      @close()
    else
      @open()

  open: =>
    _cms.vent.trigger "reset" #nb. closes us too.
    @$el.find('>.header').addClass('open')
    @_menu_view.show()

  close: =>
    @$el.find('>.header').removeClass('open')
    @_menu_view.hide()


class CMS.Views.CollectionView extends Backbone.Marionette.CollectionView
  @mixin "collection", "toggle"

  show: () =>
    @$el.show()
  
  hide: () =>
    @$el.hide()


class CMS.Views.MenuView extends Backbone.Marionette.CompositeView
  @mixin "collection", "toggle"
  childViewContainer: ".menu_items"

  showing: =>
    @$el.css('display') isnt 'none'

  show: =>
    @$el.stop().slideDown
      duration: 400
      easing: "boing"
    , =>
      @$el.css 'height', 'auto'

  hide: =>
    @$el.stop().slideUp
      duration: 400
      easing: "glide"


class CMS.Views.ItemView extends Backbone.Marionette.ItemView
  onRender: =>
    @stickit()

  log: () =>
    if _cms.logging()
      console.log "#{@constructor.name} view", arguments...

  #visibleFns
  
  visibleAsInlineBlock: ($el, isVisible, options) =>
    if isVisible
      $el.css "display", "inline-block"
    else
      $el.css "display", "none"

  visibleAsBlock: ($el, isVisible, options) =>
    if isVisible
      $el.css display: "inline-block"
    else
      $el.hide()

  #onGets

  untrue: (val) =>
    not val
    

