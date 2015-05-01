# An established session has only a token attribute and a user association. It hooks
# into the ajax call so that the token is always sent as a header and it is able to
# persist the token to a cookie.
#
# Before signing in the session exists as an unsaved object with email, password and
# otp attributes but no token. It is ready and it has a user, but the user is not ready.
# If the API is willing to return a session object when we post those values then we
# will receive our token and user data in the response, and the user will become ready.
#
# You can interact with the session and user using the same loading mechanism as elsewhere.
#
# Summary:
# The session is ready when we have gone through the validation step or decided not to.
# The user is ready when we have validated the session or created a new one.
#
class CMS.Models.Session extends CMS.Model
  idAttribute: "token"
  savedAttributes: ['email', 'password', 'otp']

  urlRoot: =>
    "#{_cms.apiUrl()}sessions"

  initialize: =>
    super
    $(document).ajaxSend @authenticateRequest
    @_loaded.fail @clearCookie

  build: () =>
    @readCookie()
    @_user = new CMS.Models.User

  load: =>
    if @get('token')
      @fetch().done @loaded
    else
      @loaded()
    @_loaded.promise()
  
  populate: (data) =>
    @log "populate", data
    @populateUser(data.user)
    @writeCookie()
    true

  getUser: () =>
    @_user
  
  userIsReady: () =>
    @_user.isReady()

  whenUserReady: (fn) =>
    @_user.whenReady(fn)
  
  # TODO: find a better way to hook into the readiness mechanism without fetching.
  populateUser: (data) =>
    @_user.populate(data)
    @_user.loaded()

  readCookie: () =>
    @set 'token', $.cookie(_cms.config('cookie_name'))

  writeCookie: () =>
    $.cookie _cms.config('cookie_name'), @get('token'),
      domain: _cms.config('cookie_domain')
      path: "/"
      expires: 7

  clearCookie: () =>
    $.removeCookie _cms.config('cookie_name'),
      domain: _cms.config('cookie_domain')
      path: "/"

  authenticateRequest: (e, request) =>
    # request.setRequestHeader("X-ClientID", _cms.clientID)
    if token = @get('token')
      request.setRequestHeader("Authorization", "Token token=#{token}")










# class CMS.Models.Session extends Backbone.Model
#   autoload: true
#
#   build: () =>
#     $(document).ajaxSend @sendAuthenticationHeaders
#     @user = null
#
#   fetch: () =>
#     if token = @authToken()
#       # treat one of the token values as session id and fetch normally?
#       $.getJSON("#{_cms.apiUrl()}/sessions/check")
#
#   populate: (data) =>
#     @user = new CMS.Models.User
#     @user.loaded(data)
#     @setCookie()
#
#   unsetUser: () =>
#     @user = null
#     @unsetCookie()
#
#   authToken: () =>
#     if @user
#       @user.get('uid') + @user.get('authentication_token')
#     else
#       @getCookie()
#
#   getCookie: () =>
#     $.cookie(_cms.config('cookie_name'))
#
#   setCookie: () =>
#     if token = @authToken()
#       $.cookie _cms.config('cookie_name'), token,
#         domain: _cms.config('cookie_domain')
#         path: "/"
#         expires: 7
#
#   unsetCookie: () =>
#     $.removeCookie _cms.config('cookie_name'),
#       domain: _cms.config('cookie_domain')
#       path: "/"
#
#   sendAuthenticationHeaders: (e, request) =>
#     # request.setRequestHeader("X-ClientID", _cms.clientID)
#     if token = @authToken()
#       request.setRequestHeader("Authorization", "Token token=#{token}")
#
