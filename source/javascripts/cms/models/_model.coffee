# Model lifecycle:
#
# 1. init sets up a promise of readiness
# 2. build sets up attributes and collections
# 3. load fetches data from the API
# 4. loaded resolves the promise, which triggers populate
# 5. populate places received data into attributes and collections
#
# Call `model.ready()` to access the readiness promise after construction
# or call `whenReady(function)` to attach more callbacks. They will
# fire after population and receive the fetched data as first argument.
#
# 6 save
#
class CMS.Model extends Backbone.Model
  @mixin 'logging'
  
  autoload: false
  savedAttributes: []

  initialize: (attributes, opts={}) ->
    @_loaded = $.Deferred()
    @build()
    @load() if @autoload
    @on "change", @changedIfSignificant
    @on "sync", @markAsUnchanged

  ready: =>
    @_loaded.promise()
    
  whenReady: (fn) =>
    @_loaded.done fn

  whenFailed: (fn) =>
    @_loaded.fail fn

  isReady: =>
    @_loaded.state() is 'resolved'

  build: =>
    # usually this is all about associates:
    # @things = new CMS.Collections.Things

  load: =>
    @fetch(error: @notLoaded).done(@loaded)
    @_loaded.promise()
  
  loaded: (data) =>
    @_loaded.resolve(data)

  notLoaded: () =>
    @_loaded.reject()
  
  parse: (data) =>
    # you can modify `data` in populate,
    # or return false to prevent the usual parse from being called at all.
    super if data and @populate(data)

  populate: (data) =>
    # @things.reset(data.things)
    @populateDates(data)
    true

  populateDates: (data) =>
    for col in ["updated_at", "published_at", "deleted_at"]
      if string = data[col]
        @set col, new Date(string)
        delete data[col]

  select: =>
    unless @get("selected")
      @collection?.findWhere(selected:true)?.set selected:false
      @set selected: true

  reload: ->
    @_loaded = $.Deferred()
    @load()

  toJSON: =>
    json = {}
    if attributes = _.result @, "savedAttributes"
      json[att] = @get(att) for att in attributes
    else
      json = super
    json

  startProgress: () =>
    @set("progress", 0)
    @set("progressing", true)

  setProgress: (p) =>
    if p.lengthComputable
      perc = Math.round(10000 * p.loaded / p.total) / 100.0
      console.log "progress", perc
      @set("progress", perc)

  finishProgress: () =>
    @set("progress", 100)
    @set("progressing", false)

  isDestroyed: () =>
    @get('deleted_at')
    
  destroyReversibly: () =>
    unless @get('deleted_at')
      @set('deleted_at', new Date) 
      @markAsChanged()

  markAsChanged: (e) =>
    @set "changed", true
  
  markAsUnchanged: () =>
    @set "changed", false
  
  changedIfSignificant: (model, options) =>
    if options.stickitChange?
      significant_changes = _.pick @changedAttributes(), @savedAttributes
      @markAsChanged() unless _.isEmpty(significant_changes)

  saveAndResume: () =>
    @save().done =>
      @markAsUnchanged()

  touch: () =>
    @set 'updated_at', new Date(), 
      stickitChange: true