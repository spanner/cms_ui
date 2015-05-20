class CMS.Views.SessionPasswordForm extends CMS.Views.ItemView
  template: 'sessions/password_form'
  className: 'reset'

  events:
    'submit form': 'setPassword'

  bindings:
    "span.name": "name"
    "#name": "name"
    "#password": "password"
    "#password_confirmation": "password_confirmation"
    ".password_confirmation":
      observe: "password"
      update: "showIfPasswordValid"
    '.buttons':
      observe: "password_confirmation"
      update: "showIfPasswordConfirmed"

  onRender: () =>
    @stickit()
    @$el.find('.waiter').show()
    @$el.find('form').hide()
    @$el.find('.confirmation').hide()
    @$el.find('.refusal').hide()

    view_state = _sis.getViewState()
    @_uid = view_state.user_uid
    @_tok = view_state.user_token
    @user_data = {}
    
    state = _sis.getSessionState()
    if @model.signedIn() and @model.confirmed()
      _sis.notify("You are already signed in")
      @$el.find('.waiter').hide()
      _sis.navigate('/')
    else
      if @model.signedIn()
        @requestPassword()
      else if @_uid and @_tok
        @$el.find('.waiter').show()
        url = "#{_sis.config('api_url')}/users/verify"
        data = 
          uid: @_uid
          reset_password_token: @_tok
        $.ajax
          url: url 
          data: data
          type: "POST"
          success: (json) =>
            @requestPassword(json)
          error: @denyAccess
      else
        @denyAccess()

  requestPassword: (json) =>
    @user_data = json
    @model.set 'name', json.name
    @stickit()
    @$el.find('.waiter').hide()
    @$el.find('form').slideDown()
    @$el.find('input#password').first().focus()
    
  denyAccess: () =>
    @$el.find('.waiter').hide()
    @$el.find('.refusal').slideDown()

  setPassword: (e) =>
    e.preventDefault()
    @$el.find('.error').remove()
    @model.setUser(@user_data)
    @model.setPassword
      onError: @fail
    
  denyAccess: () =>
    _sis.signOut()
    @$el.find('.waiter').hide()
    @$el.find('.refusal').slideDown()

  fail: (err) =>
    if error
      @$el.find('.error').text(error).show()
    else
      @$el.find('.error').text("Sorry: something not right there.").show()

  showIfPasswordValid: ($el, val, model, options) =>
    if val? and val.length >= 6
      $el.slideDown()
    else
      $el.slideUp() 

  showIfPasswordConfirmed: ($el, val, model, options) =>
    if val? and val isnt "" and val is model.get('password')
      $el.enable() 
    else
      $el.disable() 
