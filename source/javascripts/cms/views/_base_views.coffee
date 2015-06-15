class CMS.Views.LayoutView extends Backbone.Marionette.LayoutView
  @mixin "logging", "bindings"


class CMS.Views.MenuLayout extends CMS.Views.LayoutView
  events:
    "click a.cms-menu-head": "toggleMenu"

  bindings:
    'a.cms-menu-head':
      observe: "title"
      updateMethod: "html"

  initialize: ->
    super
    @collection?.on "change:selected", @setModel
    _cms.vent.on "reset_menus", @close

  onRender: =>
    if menu_view_class = @getOption('menuView')
      @_menu_view = new menu_view_class
        el: @$el.find(".cms-menu-body")
        collection: @collection
      @_menu_view.render()
    @setModel() if @collection

  toggleMenu: =>
    if @showing()
      @close()
    else
      @open()

  showing: =>
      @$el.hasClass('open')

  open: =>
    _cms.vent.trigger "reset_menus"
    @$el.addClass('open')
    @_menu_view?.show()

  close: =>
    @$el.removeClass('open')
    @_menu_view?.hide()
    
  setModel: =>
    @model = @collection.findWhere(selected: true)
    @stickit() if @model


class CMS.Views.MenuView extends Backbone.Marionette.CompositeView
  @mixin "collection", "toggle", "bindings"
  childViewContainer: ".cms-menu-items"
  
  events: =>
    "click a.add_item": "addItem"
  
  onRender: =>
    console.log "menu_view rendered in", @el

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

  addItem: =>
    @collection.add({})


class CMS.Views.CollectionView extends Backbone.Marionette.CollectionView
  @mixin "collection", "toggle", "bindings"

  show: () =>
    @$el.show()
  
  hide: () =>
    @$el.hide()


class CMS.Views.ItemView extends Backbone.Marionette.ItemView
  @mixin "bindings"

  onRender: =>
    @stickit()

  log: () =>
    if _cms.logging()
      console.log "#{@constructor.name} view", arguments...

