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
  autoload: false
  savedAttributes: []

  initialize: (attributes, opts={}) ->
    @_loaded = $.Deferred()
    @build()
    @load() if @autoload

  ready: =>
    @_loaded.promise()
    
  whenReady: (fn) =>
    @_loaded.done fn

  isReady: =>
    @_loaded.isResolved()

  build: =>
    # usually this is all about associates:
    # @things = new CMS.Collections.Things

  load: =>
    @fetch().done @loaded
    @_loaded.promise()
  
  loaded: (data) =>
    @_loaded.resolve(data)

  parse: (data) =>
    # you can modify `data` in populate, 
    # or return false to prevent the usual parse from being called at all.
    super if @populate(data)

  populate: (data) =>
    # @things.reset(data.things)
    true

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

