class CMS.Model extends Backbone.Model

  initialize: (properties, opts={}) ->
    @build()
    #

  build: ->
    #noop here

  populate: ->
    #noop here

  isPopulated: =>
    @get 'populated'
