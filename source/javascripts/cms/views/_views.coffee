class CMS.Views.LayoutView extends Backbone.Marionette.LayoutView
  @mixin "logging", "bindings"


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
    @collection.on "change:selected", @setModel

  onRender: =>
    if menu_view_class = @getOption('menuView')
      @_menu_view = new menu_view_class
        el: @$el.find(".menu")
        collection: @collection
      @_menu_view.render()
    @setModel()

  toggleMenu: =>
    if @showing()
      @close()
    else
      @open()

  showing: =>
    @_menu_view.showing()

  open: =>
    if @_menu_view?
      _cms.vent.trigger "reset" #nb. closes us too.
      @$el.find('>.header').addClass('open')
      @_menu_view.show()

  close: =>
    if @_menu_view?
      @$el.find('>.header').removeClass('open')
      @_menu_view.hide()
    
  setModel: =>
    @model = @collection.findWhere(selected: true)
    @stickit() if @model


class CMS.Views.CollectionView extends Backbone.Marionette.CollectionView
  @mixin "collection", "toggle", "bindings"

  show: () =>
    @$el.show()
  
  hide: () =>
    @$el.hide()


class CMS.Views.MenuView extends Backbone.Marionette.CompositeView
  @mixin "collection", "toggle", "bindings"
  childViewContainer: ".menu_items"
  
  events: =>
    "click a.add_item": "addItem"
  
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


class CMS.Views.ItemView extends Backbone.Marionette.ItemView
  @mixin "bindings"

  onRender: =>
    @stickit()

  log: () =>
    if _cms.logging()
      console.log "#{@constructor.name} view", arguments...

