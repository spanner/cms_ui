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
    "sites/:site_slug/pages/:page_id/sections/:section_uid(/)": "siteView"
    "sites/:site_slug/pages/:page_id(/)": "siteView"
    "sites/:site_slug(/)": "siteView"
    "session/:action": "sessionView"
    "(/)": "homeView"

class CMS.Application extends Backbone.Marionette.Application
  initialize: (options={}) ->
    root._cms = @
    @_config = new CMS.Config(options.config)
    @_session = new CMS.Models.Session
    @_ui = new CMS.Views.UILayout
      model: @_session
      el: "#cms"
    @_router = new CMS.AppRouter(controller: @_ui)
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
    Backbone.history.navigate route,
      trigger: trigger
      replace: replace
