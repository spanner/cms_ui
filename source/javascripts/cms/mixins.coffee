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
CMS.Mixins.CommonBindings = 

  #visibleFns
  
  visibleAsInlineBlock: ($el, isVisible, options) ->
    if isVisible
      $el.css "display", "inline-block"
    else
      $el.css "display", "none"

  visibleAsBlock: ($el, isVisible, options) ->
    if isVisible
      $el.css display: "inline-block"
    else
      $el.hide()

  slideVisibility: ($el, isVisible, options) ->
    console.log "slideVisibility", $el, isVisible, options
    if isVisible
      $el.slideDown()
    else
      console.log "sliding Up"
      $el.slideUp () =>
        $el.hide()


  #visibility controls
  

  untrue: (val) ->
    not val

  thisOrNotThat: ([value, other_value]=[]) ->
    value or not other_value

  thisAndThat: ([value, other_value]=[]) ->
    value and other_value

  thisButNotThat: ([value, other_value]=[]) ->
    value and not other_value
  
  notTheSame: ([value, other_value]=[]) ->
    value isnt other_value

  notTheSameOrNotTheSame: ([value1, other_value1, value2, other_value2]=[]) ->
    value1 isnt other_value1 or value2 isnt other_value2

  #onGets
  
  thisOrThat: ([value, other_value]=[]) ->
    value or other_value

  # for observed attributes that are assets:
  assetUrl: (asset, style) =>
    if asset?
      asset.get("#{style}_url") ? asset.get('url')
    else
      ""

  assetBackgroundUrl: (asset, style) =>
    if url = @assetUrl(asset, style)
      "background-image: url('#{url}')"
    else
      ""
  
  truncate12: (value) =>
    _.truncate value, 12
  
  cleanText: (value) =>
    $(value).text() or value
    
  # for observed asset attributes:

  backgroundUrl: (url) =>
     "background-image: url(#{url})"

  showDescent: (path) =>
    if path is "/"
      ""
    else
      depth = (path.match(/\//g) || []).length
      trail = ''
      if depth > 0
        trail += '<span class="d"></span>' for [1..depth]
      trail

  # useful
  #
  containEvent: (e) ->
    e?.stopImmediatePropagation()



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
  bindings: CMS.Mixins.CommonBindings
  item: CMS.Mixins.Item
  collection: CMS.Mixins.Collection
  parental: CMS.Mixins.Parental
  toggle: CMS.Mixins.Toggle
  logging: CMS.Mixins.Logging
  text: CMS.Mixins.Text
