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
    @_original_attributes = _.pick @attributes, @savedAttributes
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
    unless @isReady()
      @fetch(error: @notLoaded).done(@loaded)
    @_loaded.promise()
  
  loaded: (data) =>
    @_loaded.resolve(data)

  notLoaded: () =>
    @_loaded.reject()
  
  parse: (data) =>
    # you can modify `data` in populate,
    # or return false to prevent the usual parse from being called at all.
    # but you don't really want to override `parse`
    if @populate(data)
      @_original_attributes = _.pick @attributes, @savedAttributes
      data

  populate: (data) =>
    # @things.reset(data.things)
    @populateDates(data)
    true

  populateDates: (data) =>
    for col in ["created_at", "updated_at", "published_at", "deleted_at"]
      if string = data[col]
        @set col, new Date(string)
        delete data[col]

  # belongsTo sets up the listeners involved in maintaining a one-to-one association.
  # It allows us to fetch and save an object_id while working in the UI with the instantiated object.
  # The object has to be gettable from the supplied collection using the object_id.
  #
  # The UI and any view bindings should always use the object_attribute
  # (eg set or bind to 'video', not 'video_id').
  # The id_attribute is only for use upwards, to and from the API.
  #
  belongsTo: (object_attribute, id_attribute, collection) =>
    # turn received object_id into associated object
    if object_id = @get(id_attribute)
      console.log "belongsTo", object_attribute, object_id, collection.get(object_id), 'in', collection.size()
      @set object_attribute, collection.get(object_id), silent: true

    # on any change, turn associated object back into an object_id
    @on "change:#{object_attribute}", (me, it, options) =>
      if it
        if id = it.get('id')
          @set id_attribute, id, stickitChange: true
        else
          it.once "change:id", (it_again, new_id) =>
            @set id_attribute, new_id, stickitChange: true
      else
        @set id_attribute, null, stickitChange: true

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
      @set "changed", not _.isEmpty @significantChangedAttributes()

  significantChangedAttributes: () =>
    significantly_changed = _.pick @changedAttributes(), @savedAttributes
    actually_changed_keys = _.filter _.keys(significantly_changed), (k) =>
      significantly_changed[k] isnt @_original_attributes[k]
    _.pick significantly_changed, actually_changed_keys

  saveAndResume: () =>
    @save().done =>
      @markAsUnchanged()

  touch: () =>
    @set 'updated_at', new Date(),
      stickitChange: true