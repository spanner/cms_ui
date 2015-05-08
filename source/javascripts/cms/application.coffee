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
    @_config = new CMS.Config
    @_session = new CMS.Models.Session
    @_ui = new CMS.Views.UILayout
      model: @_session
      el: "#cms"
    @_router = new CMS.AppRouter
      controller: @_ui
    @_ui.render()
    @_session.load().always () =>
      console.log "Boot!"
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
    console.log "navigate", route
    trigger ?= true
    hash_link = new RegExp(/^\#/)
    if hash_link.test(route)
      window.location.hash = route
    else
      Backbone.history.navigate route,
        trigger: trigger
        replace: replace

