class CMS.Views.SessionLoginForm extends Backbone.Marionette.ItemView
  template: 'sessions/login_form'

  events:
    'submit form': 'doLogin'

  bindings:
    "#email": "email"
    "#password": "password"
    "span.name": "name"

  onRender: () =>
    @stickit()

  doLogin: (e) =>
    e.preventDefault()
    @$el.find('.error').empty()
    @$el.find('input[type="submit"]').addClass('waiting')
    url = "#{_cms.apiUrl()}sessions"
    data =
      user:
        email: @model.get('email')
        password: @model.get('password')
    $.ajax
      url: url
      type: "post"
      data: data
      success: @succeed
      error: @fail

  succeed: (json) =>
    if json.status is 'insufficient_auth'
      @$el.find('input[type="submit"]').removeClass('waiting')
      @$el.find('a.forgotten').hide()
      @model.set
        account_name: json.account_name
        name: json.name
        email: json.email
      # @$el.find('.error').text("something isn't right").show()
      @stickit()
    else
      @$el.find('.error').text("").hide()
      @model.clearAuthWorking()
      @model.setUser(json)

  fail: (xhr, status, error) =>    
    @$el.find('input[type="submit"]').removeClass('waiting')
    @model.set('password', "")
    if error
      @$el.find('.error').text(error).show()
    else
      @$el.find('.error').text("Sorry: something not right there.").show()
