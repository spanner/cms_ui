## Mixins
#
# Common view and model functionality is bundled in shared components that can be mixed in just by calling
#
#   @mixin '...'
#
# In a view class definition. 
#
# Warning: beware of this-context. Mixed-in functions should always be single-arrowed (so as not to 
# keep them bound to the mixin class) but this can make internal reference difficult. 


# ### View Mixins
CMS.Mixins.Crumbed = {}


CMS.Mixins.Text =
  paste: (e) ->
    e.preventDefault()
    document.execCommand("insertHTML", false, e.originalEvent.clipboardData.getData("text/plain"))
    

CMS.Mixins.Item =
  setModel: (model) ->
    @model = model
    if @model
      @model.populate()
      @stickit()
    else
      @unstickit()
      @render()


CMS.Mixins.Collection =
  setCollection: (collection) ->
    @collection = collection
    @render()

CMS.Mixins.Parental =
  showChild: (layout, properties={}) ->
    if @_child and not @_child.isDestroyed and @_child.constructor is CMS.Views[layout] and properties.path
      @_child.setPath?(properties.path)
    else
      @showNewChild layout, properties

  showNewChild: (layout, properties) ->
    @_child = new CMS.Views[layout](properties)
    @childRegion.show @_child


CMS.Mixins.Toggle =
  show: ->
    @$el.show()

  hide: ->
    @$el.hide()


CMS.Mixins.Logging =
  log: (message) =>
    if _cms.logging()
      console.log "#{@constructor.name}", message

  logWithStack: (message) =>
    e = new Error('dummy');
    stack = e.stack.replace(/^[^\(]+?[\n$]/gm, '')
      .replace(/^\s+at\s+/gm, '')
      .replace(/^Object.<anonymous>\s*\(/gm, '{anonymous}()@')
      .split('\n')
    console.log message, stack


Cocktail.mixins =
  crumbed: CMS.Mixins.Crumbed
  item: CMS.Mixins.Item
  collection: CMS.Mixins.Collection
  parental: CMS.Mixins.Parental
  toggle: CMS.Mixins.Toggle
  logging: CMS.Mixins.Logging
  text: CMS.Mixins.Text
