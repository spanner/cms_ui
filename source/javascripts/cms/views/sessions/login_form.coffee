class CMS.Views.SessionLoginForm extends CMS.Views.ItemView
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
    @model.save().done @succeed

  succeed: (json) =>
    @model.setUser(json)

  fail: (xhr, status, error) =>    
    @$el.find('input[type="submit"]').removeClass('waiting')
    @model.set('password', "")
    if error
      @$el.find('.error').text(error).show()
    else
      @$el.find('.error').text("Sorry: something not right there.").show()
