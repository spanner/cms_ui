class CMS.Models.User extends CMS.Model
  savedAttributes: ['email', 'name', 'password', 'password_confirmation', 'otp_secret']
  idAttribute: "uid"

  readinessCriteria:
    name: "populatedString"
    email: "validEmail"

  url: =>
    "#{_cms.apiUrl()}users/#{@get("uid")}"

  build: =>
    @sites = new CMS.Collections.Sites @get("sites")

  populate: (data) =>
    @sites.reset(data.sites)






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

