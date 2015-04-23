# The session holds our current authentication state as a user object.
# It is a simple state machine with these states:
# * unknown: not authenticated
# * pending: pending authentication
# * unconfirmed: authenticated but unconfirmed
# * confirmed: authenticated and confirmed
# * failed: authentication attempt failed
#
# State changes are signalled with CMS.vent events in the auth. namespace. 
# At the moment we just trigger 'auth.changed', which causes re-renders in user-specific views.
#
class CMS.Models.Session extends Backbone.Model
  @unknownState: 'Unknown'
  @pendingState: 'Authentication in progress'
  @factorRequiredState: 'User is not fully authenticated'
  @unconfirmedState: 'User account is not confirmed'
  @confirmedState: 'User account is confirmed'
  @failedState: 'User credentials are not correct'

  defaults:
    state: @unknownState
    email: ""
    password: ""
    password_confirmation: ""
  
  # The session is both a holder of status and a broker of intentions.
  #
  initialize: (options) ->
    @user = new CMS.Models.User()
    @_cookie_name = _cms.config('cookie_name')
    @_cookie_domain = _cms.config('cookie_domain')
    @_api_url = _cms.config('api_url')
    $(document).ajaxSend @sendAuthenticationHeaders
    @on "change:state", @changedState
    @on "change:view_state", @changedViewState
    @load()
    
  ## Percmstence
  #
  # The session stores a cookie containing its user's uid and (safely hashed) auth_token.
  # On initialization we request user data from the back end; if the uid/token are valid,
  # this call will return a packet of user data that we can use to populate the session 
  # user object. The uid/token don't need to be passed explicitly: they are given in the 
  # request header in the usual way.
  #
  load: () =>
    if token = @authToken()
      @set "state", CMS.Models.Session.pendingState
      $.getJSON("#{@_api_url}/users/me").done(@setUser).fail(@unsetUser)
    else
      @unsetUser()

  reset: () =>
    @user ?= new CMS.Models.User()
    @user.clear()
    @setState()
    @unsetCookie()


  ## User state
  #
  # setUser is called from various form views to supply user data that they
  # have received from the server, eg on registration or signing in.
  #
  setUser: (data) =>
    @user = new CMS.Models.User(data)
    @set "name", @user.get("name")
    @user.on "change:status", @setState
    @user.on "destroy", @reset
    @setCookie()
    @setState()

  setPassword: (callbacks={}) =>
    callbacks.onError ?= @clearPasswords
    callbacks.onSuccess ?= (data) -> 
      _cms.navigate("/")
    @user?.save
      password: @get('password')
      password_confirmation: @get('password_confirmation')
    ,
      error: callbacks.onError
      success: callbacks.onSuccess

  setPasswordAndMFA: (callbacks={}) =>
    callbacks.onError ?= @clearPasswords
    callbacks.onSuccess ?= (data) ->
      _cms.navigate("/")
    if @user?
      @user.set
        password: @get('password')
        password_confirmation: @get('password_confirmation')
        otp_secret: @get('otp_secret')
        otp_attempt: @get('otp_attempt')
      @user.save {},
        error: callbacks.onError
        success: callbacks.onSuccess

  clearPasswords: () =>
    @unset('password')
    @unset('password_confirmation')

  clearAuthWorking: () =>
    @clearPasswords()
    @unset('mfa_missing')
    @unset('otp_secret')
    @unset('otp_attempt')
    @user?.unset('otp_secret')
    
  unsetUser: () =>
    @user = null
    @unsetCookie()
    @setState()

  checking: () =>
    @get("state") is CMS.Models.Session.pendingState

  signedIn: () =>
    @user and not @user.isNew()

  confirmed: () =>
    @user and @user.get('status') is "confirmed" or @user.get('status') is "admin"

  secondFactorRequired: () =>
    @user and @user.get('status') is "insufficient_auth"
    
  admin: () =>
    @user and @user.get('admin')

  # And nearly all of them re-render when they see an 'auth.change' event,
  # which is usually triggered by setting state here.
  #
  setState: () =>
    if !@signedIn()
      @set "state", CMS.Models.Session.unknownState
    else if @secondFactorRequired()
      @set "state", CMS.Models.Session.factorRequiredState
    else if @confirmed()
      @set "state", CMS.Models.Session.confirmedState
    else
      @set "state", CMS.Models.Session.unconfirmedState

  changedState: (model, value, options) =>
    _cms.vent.trigger('auth.change', value)

  getState: () =>
    @get('state')


  ## View state
  #
  # The session also acts as a broker for the desired view state, which is loaded from 
  # path parameters at a time when session information hasn't been verified yet. We hold
  # it here, and broadcast a view.change event upon later navigation.
  #
  setViewState: (state) =>
    @set "view_state", state
    
  changedViewState: (model, value, options) =>
    _cms.vent.trigger('view.change', value)
    
  getViewState: () =>
    @get("view_state") ? {}


  ## API authentication
  #
  # sendAuthenticationHeaders is called on every API call
  #
  sendAuthenticationHeaders: (e, request) =>
    # request.setRequestHeader("X-ClientID", _cms.clientID)
    if token = @authToken()
      request.setRequestHeader("Authorization", "Token token=#{token}")

  # Usually the uid and token come from the signed-in user, but on initialisation we don't
  # have the user yet: in that case we try the cookie token instead. If the request succeeds
  # the user becomes available.
  #
  authToken: () =>
    if @signedIn()
      @user.get('uid') + @user.get('authentication_token')
    else if stored_token = @getCookie()
      stored_token

  getCookie: () =>
    $.cookie(@_cookie_name)

  setCookie: () =>
    if token = @authToken()
      $.cookie @_cookie_name, token,
        domain: @_cookie_domain
        path: "/"
        expires: 7

  unsetCookie: () =>
    $.removeCookie @_cookie_name,
      domain: @_cookie_domain
      path: "/"

