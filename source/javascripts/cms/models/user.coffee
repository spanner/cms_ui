class CMS.Models.User extends CMS.Model
  savedAttributes: ['email', 'name', 'password', 'password_confirmation', 'otp_secret']
  idAttribute: "uid"

  readinessCriteria:
    name: "populatedString"
    email: "validEmail"

  url: =>
    "#{_cms.apiUrl()}users/#{@get("uid")}"

  initialize: =>
    $(document).ajaxSend @authenticateRequest
    super

  build: =>
    @sites = new CMS.Collections.Sites @get("sites")

  populate: (data) =>
    console.log "user.populate", data
    @sites.reset(data.sites)

  readCookie: () =>
    @set 'token', $.cookie(_cms.config('cookie_name'))

  authenticateRequest: (e, request) =>
    # request.setRequestHeader("X-ClientID", _cms.clientID)
    if token = @get('token')
      request.setRequestHeader("Authorization", "Token token=#{token}")





  # passwordCheck: =>
  #   url = "#{_sis.config('auth_url')}/users/sign_in.json"
  #   data =
  #     user:
  #       email: @get('email')
  #       password: @get("password_check")
  #   $.ajax url,
  #     dataType: "json"
  #     method: "POST"
  #     data: data
  #     success: @passwordAuthenticated
  #     error: @wrongPassword
  #
  # passwordAuthenticated: =>
  #   @set password_authenticated: true
  #   _.delay @authenticationExpired, 5 * 1000 * 60
  #
  # notPasswordAuthenticated: =>
  #   @set password_authenticated: false
  #
  # authenticationExpired: =>
  #   @notPasswordAuthenticated()
  #
  # wrongPassword: =>
  #   @trigger "auth.error"
  #   @notPasswordAuthenticated()

