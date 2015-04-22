class CMS.Views.StackLayout extends Backbone.Marionette.LayoutView

  className: "stacked"

  regions: 
    stackRegion: ".stack"

  routes: =>
    {}

  # Path changes will often pass through a stack level without changing it. For stack views where
  # a path segment determines our behaviour (which is usual) the path segment should be remembered
  # and if it has not changed, no rendering should be performed.
  #
  # A stack view whose instructions have changed will may show a new subview or may only receive a new model.
  # It is usually re-rendered but it will not be reinitialized so the initializer should be kept minimal.
  #
  initialize: (options) ->
    @_child = null
    @placeInStack(options)
    @_router = new CMS.Router
      routes: _.result(this, 'routes')

  onRender: () =>
    @log "render"
    @stickit()
    @stackit()

  # For stack levels where the tree does not branch you can override stackit to bypass the router,
  # but in that case you probably don't want it to be a layout at all.
  #
  stackit: () =>
    unless @_path? and @_router.handle(@_path)
      @redrawAbove()

  setPath: (path) ->
    @_path = path ? ""
    @stackit()

  # use or reuse a child view
  #
  showChild: (layout, properties={}) =>
    if @_child and not @_child.isDestroyed and @_child.constructor is SIS.Views[layout] and properties.path
      @_child.setPath?(properties.path)
    else
      properties.trail ?= @_trail
      @showNewChild layout, properties
      _sis.vent.trigger "stacked"

  # leaf views are badly named. The difference is that they have no onward path mechanism.
  #
  showLeaf: (layout, properties) =>
    if @_child and not @_child.isDestroyed and @_child.constructor is SIS.Views[layout]
      @_child.model = properties.model
      @_child.collection = properties.collection
    else
      @showNewChild layout, properties

  # force the creation of a new child view
  #
  showNewChild: (layout, properties) =>
    @log "showNewChild", layout, properties
    @_child = new SIS.Views[layout](properties)
    @stackRegion.show @_child

  showError: (code, message) =>
    @showNewChild "StackError", 
      model: new SIS.Models.Error
        code: code
        message: message
