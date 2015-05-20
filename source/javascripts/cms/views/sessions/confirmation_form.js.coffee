class CMS.Views.SessionConfirmationForm extends CMS.Views.ItemView
  template: 'sessions/confirmation_form'
  className: 'confirmation'

  events:
    'submit form': 'doConfirmation'

  bindings:
    "span.name": "name"
    "#name": "name"
    "#password": 
      observe: "password"
      attributes: [
        name: "class"
        onGet: "tickIfValidPassword"
      ]
    "#password_confirmation": 
      observe: "password_confirmation"
      attributes: [
        name: "class"
        onGet: "tickIfPasswordConfirmed"
      ]
    "#otp_attempt": 
      observe: "otp_attempt"
      attributes: [
        name: "class"
        onGet: "tickIfValidAuthCode"
      ]
    ".password_confirmation":
      observe: "password"
      update: "enableIfPasswordValid"
    ".second_factor":
      observe: "mfa_required"
      visible: true
    ".qrcode":
      observe: ["account_name", "email", "otp_secret"]
      update: "setQRCode"
    '.buttons':
      observe: ["password_confirmation", "mfa_required", "otp_secret", "otp_attempt"]
      update: "enableIfReady"

  onRender: () =>
    @stickit()
    @$el.find('form').hide()
    @$el.find('.confirmation').hide()
    @$el.find('.refusal').hide()

    view_state = _sis.getViewState()
    @_uid = view_state.user_uid
    @_tok = view_state.user_token

    state = _sis.getSessionState()
    if @model.signedIn() and @model.confirmed() and @model.fullyAuthenticated()
      _sis.notify("Your account is already set up")
      @$el.find('.waiter').hide()
      _sis.navigate('/')

    else
      if @_uid and @_tok
        @$el.find('.waiter').show()
        url = "#{_sis.config('api_url')}/users/verify"
        data = 
          uid: @_uid
          confirmation_token: @_tok
        $.ajax
          url: url 
          data: data
          type: "POST"
          success: @confirmationOk
          error: @denyAccess
      else
        @denyAccess()

  confirmationOk: (json) =>
    for key in ['account_name', 'mfa_required', 'mfa_set', 'mfa_missing']
      @model.set key, json[key]
      delete json[key]
    @model.set 'name', json.name
    @model.set 'email', json.email
    @model.set 'otp_secret', json.suggested_otp_secret
    @model.setUser(json)
    @requestPassword()

  requestPassword: () =>
    @$el.find('.waiter').hide()
    @$el.find('.refusal').hide()
    @$el.find('form').show()
    @$el.find('#password').focus()
    
  denyAccess: () =>
    _sis.signOut()
    @$el.find('form').hide()
    @$el.find('.waiter').hide()
    @$el.find('.refusal').show()

  doConfirmation: (e) =>
    @$el.find('input[type="submit"]').addClass('waiting')
    e.preventDefault()
    @$el.find('.error').remove()
    @model.setPasswordAndMFA
      onError: @retry
      onSuccess: @complete

  retry: (xhr, status, error) =>
    @$el.find('input[type="submit"]').removeClass('waiting')
    if error
      @$el.find('.error').text(error).show()
    else
      @$el.find('.error').text("Sorry: something is not right there. Please try again.").show()

  complete: (user) =>
    if user.get('status') is "insufficient_auth"
      @$el.find('.error').text("Sorry: your MFA code didn't match. Please try again with this new code.").show()
      @model.unset "otp_attempt"
    else
      @model.clearAuthWorking()
      _sis.navigate("/")
      _sis.remark "Thank you. Your account is now fully active. To get started please click on the SIS button at top left: a row of app icons will appear for you to choose from."

  setQRCode: ($el, [account_name, email, otp_secret], model, options) =>
    if otp_secret
      issuer = _sis.config('mfa_name') + ": " + account_name
      text = "otpauth://totp/#{encodeURIComponent(email)}?secret=#{otp_secret}&issuer=#{encodeURIComponent(issuer)}"
      @$el.find('.setup').show()
      if @_qrcode?
        @_qrcode.clear()
        @_qrcode.makeCode text
      else
        @_qrcode = new QRCode(@$el.find('.qrcode')[0], text)
    else
      @$el.find('.setup').hide()
      
  enableIfPasswordValid: ($el, val, model, options) =>
    if @validPassword(val)
      $el.enable()
    else
      $el.disable() 

  enableIfPasswordConfirmed: ($el, val, model, options) =>
    if @passwordConfirmed(val)
      $el.enable() 
    else
      $el.disable() 

  enableIfReady: ($el, [password_confirmation, mfa_required, otp_secret, otp_attempt], model, options) =>
    if @passwordConfirmed(password_confirmation) and @mfaOk(mfa_required, otp_secret, otp_attempt)
      $el.enable() 
    else
      $el.disable() 

  mfaOk: (required, secret, attempt) =>
    not required or (not _.isBlank(secret) and attempt.length is 6)

  tickIfValidPassword: (val) =>
    if !val? or val.length is 0
      ""
    else if @validPassword(val)
      "valid"
    else
      "invalid"

  tickIfPasswordConfirmed: (val) =>
    if !val? or val.length is 0
      ""
    else if @validPassword(val) and @passwordConfirmed(val)
      "valid"
    else
      "invalid"

  tickIfValidAuthCode: (val) =>
    if !val? or val.length is 0
      ""
    else if @validAuthCode(val)
      "valid"
    else
      "invalid"  
    
  validPassword: (val) =>
    val? and val.length >= 6
    
  validAuthCode: (val) =>
    val? and val.length == 6
    
  passwordConfirmed: (val) =>
    val? and val isnt "" and val is @model.get('password')
