CMS = {}
CMS.version = '0.0.1'
CMS.subtitle = "Alpha 1"

CMS.Models = {}
CMS.Collections = {}
CMS.Views = {}
CMS.Behaviors = {}
CMS.Mixins = {}

root = exports ? this
root.CMS = CMS


class CMS.AppRouter extends Backbone.Marionette.AppRouter
  appRoutes:
    "sites/:site_slug(/*path)": "siteView"
    "session/:action": "sessionView"
    "(/)": "homeView"


class CMS.Application extends Backbone.Marionette.Application
  initialize: ->
    root._cms = @
    @original_backbone_sync = Backbone.sync
    Backbone.sync = @sync
    Backbone.Marionette.Renderer.render = @render
    @_config = new CMS.Config
    @_session = new CMS.Models.Session
    @_ui = new CMS.Views.UILayout
      model: @_session
      el: "#cms-ui"
    @_router = new CMS.AppRouter
      controller: @_ui
    @_ui.render()
    @_session.load().always () =>
      Backbone.history.start
        pushState: true

  config: (key) =>
    @_config.get(key)

  apiUrl: =>
    @config('api_url')

  currentUser: =>
    @_session.getUser()

  notify: (message, type)=>
    console.debug "Notify!", message, type

  logging: () =>
    true

  navigate: (route, {trigger:trigger,replace:replace}={}) =>
    trigger ?= true
    hash_link = new RegExp(/^\#/)
    if hash_link.test(route)
      window.location.hash = route
    else
      Backbone.history.navigate route,
        trigger: trigger
        replace: replace

  ## Overrides
  #
  # Override sync to add a progress listener to every save
  #
  sync: (method, model, opts) =>
    console.log "sync", method, model?.constructor.name
    unless method is "read"
      original_success = opts.success
      model.startProgress()
      opts.beforeSend = (xhr, settings) ->
        settings.xhr = () ->
          xhr = new window.XMLHttpRequest()
          xhr.upload.addEventListener "progress", (e) ->
            model.setProgress e
          , false
          xhr
      opts.success = (data, status, request) ->
        model.finishProgress(true)
        original_success(data, status, request)
    @original_backbone_sync method, model, opts

  # And render uses our hamlcoffee templates through JST
  #
  render: (template, data) ->
    if template?
      if JST[template]
        JST[template](data)
      else if _.isFunction(template)
        template(data)
      else
        template
    else
      ""
