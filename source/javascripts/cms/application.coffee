_.mixin(_.str.exports())

CMS = {}
CMS.version = '0.0.1'
CMS.subtitle = "Beta 1"
CMS.Mixins = {}
CMS.Models = {}
CMS.Collections = {}
CMS.Views = {}

root = exports ? this
root.CMS = CMS

class CMS.Application extends Backbone.Marionette.Application
  regions:
    mainRegion: "[data-cms='index']"

  initialize: (options={}) ->
    root._cms = @
    @clientID = $.makeGuid()
    Backbone.Marionette.Renderer.render = @render
    @_config = new CMS.Config(options.config)
    @_api_url = _cms.config('api_url')
    @_session = new CMS.Models.Session

    # root router only has a single path, whose job is to set the stack going.
    @_router = new Backbone.Router
      routes:
        "*path": (path="") =>
          if @_uiView?
            @_uiView.setPath(path)
          else
            @_uiView = new CMS.Views.UILayout
              model: @_session
              path: path
            @mainRegion.show @_uiView

    Backbone.history.start
      pushState: true

  config: (key) =>
    @_config.get(key)
    
  logging: =>
    @config('logging')

  currentUser: =>
    @_session.user

  notify: (message, type)=>
    console.debug "Notify!", message, type

  navigate: (route, {trigger:trigger,replace:replace}={}) =>
    trigger ?= true
    Backbone.history.navigate route,
      trigger: trigger
      replace: replace

  render: (template, data) ->
    if template?
      throw("Template '" + template + "' not found!") unless JST[template]
      JST[template](data)
    else
      ""

  apiUrl: =>
    @_api_url
