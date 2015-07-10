class CMS.Views.LayoutView extends Backbone.Marionette.LayoutView
  @mixin "logging", "bindings"


class CMS.Views.MenuLayout extends CMS.Views.LayoutView
  events:
    "click a.cms-menu-head": "toggleMenu"

  initialize: ->
    super
    @collection?.on "change:selected", @setModel
    _cms.vent.on "reset_menus", @close

  onRender: () =>
    #noop

  toggleMenu: =>
    console.log "toggleMenu"
    if @showing()
      @close()
    else
      @open()

  showing: =>
      @$el.hasClass('open')

  open: =>
    console.log "open menu"
    _cms.vent.trigger "reset_menus"
    @_menu_view?.remove()
    if menu_view_class = @getOption('menuView')
      @_menu_view = new menu_view_class
        model: @model
        collection: @collection
      @_menu_view.render()
    @$el.find(".cms-menu-body").append(@_menu_view.el)
    @_menu_view.open()
    @triggerMethod 'open', this
  
  onOpen: () =>
    @$el.addClass('open')
    @$el.parents('section').addClass('open')

  close: =>
    @_menu_view?.closeAndRemove () =>
      @$el.removeClass('open')
      @$el.parents('section').removeClass('open')
    
  setModel: =>
    @model = @collection.findWhere(selected: true)
    @stickit() if @model


class CMS.Views.MenuView extends Backbone.Marionette.CompositeView
  @mixin "collection", "toggle", "bindings"
  tagName: "div"
  className: "cms-menu-content"
  childViewContainer: ".cms-menu-items"
  
  events:
    "click a.add_item": "addItem"

  onRender: =>
    console.log "menuview render", @constructor.name
    @stickit() if @model

  addItem: =>
    @collection.add({})

  open: =>
    @$el.slideDown 'fast'
    
  closeAndRemove: (callback) =>
    @$el.slideUp 'fast', =>
      @remove()
      callback?()
    

class CMS.Views.CollectionView extends Backbone.Marionette.CollectionView
  @mixin "logging", "collection", "toggle", "bindings"

  show: () =>
    @$el.show()
  
  hide: () =>
    @$el.hide()


class CMS.Views.ItemView extends Backbone.Marionette.ItemView
  @mixin "bindings"

  onRender: =>
    @stickit() if @model

  log: () =>
    if _cms.logging()
      console.log "#{@constructor.name} view", arguments...

  save: =>
    @model?.save()

