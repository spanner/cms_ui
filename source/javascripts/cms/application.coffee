CMS = {}
CMS.version = '0.0.1'
CMS.subtitle = "Alpha 1"

CMS.Models = {}
CMS.Collections = {}
CMS.Views = {}
CMS.Behaviors = {}

root = exports ? this
root.CMS = CMS

# NB. the app router is actually calling methods on the UI layout view.
# This can be done in a direct way because no routing happens until the
# session has been checked.
#
class CMS.AppRouter extends Backbone.Marionette.AppRouter
  appRoutes:
    "sites/:site_slug/pages/:page_id/sections/:section_uid(/)": "show"
    "sites/:site_slug/pages/:page_id(/)": "show"
    "sites/:site_slug(/)": "show"
    ":action": "session"
    "(/)": "home"

class CMS.Application extends Backbone.Marionette.Application
  initialize: (options={}) ->
    @_config = new CMS.Config(options.config)
    @_session = new CMS.Models.Session
    @_ui = new CMS.Views.UILayout
      model: @_session
      el: "#cms"
    @_router = new CMS.AppRouter(controller: @_ui)

    # Our session is ready as soon as the existing token has been accepted or discarded.
    # The manager will not display anything useful until the user is also ready, but the
    # session view might have work to do before then.
    # nb. `.always` because a dead session will look like load failure.
    @_session.load().always () =>
      Backbone.history.start
        pushState: true
    @_ui.render()

  config: (key) =>
    @_config.get(key)

  apiUrl: =>
    @config('api_url')

  currentUser: =>
    @_session.getUser()

  notify: (message, type)=>
    console.debug "Notify!", message, type

  navigate: (route, {trigger:trigger,replace:replace}={}) =>
    trigger ?= true
    Backbone.history.navigate route,
      trigger: trigger
      replace: replace
