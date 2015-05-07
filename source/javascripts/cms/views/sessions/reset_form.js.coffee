class CMS.Views.SessionResetForm extends CMS.Views.ItemView
  template: 'sessions/reset_form'

  events:
    'submit form': 'doReset'

  bindings:
    "#email": "email"
    "span.email": 
      observe: "email"
      update: "checkValidity"

  onRender: () =>
    @_form = @$el.find('form')
    @_notes = @$el.find('p.note')
    @_confirmation = @$el.find('.confirmation')
    @stickit()

  doReset: (e) =>
    e.preventDefault()
    @$el.find('.error').remove()
    @_form.find('input[type="submit"]').disable()
    url = "#{_sis.config('auth_url')}/users/password.json"
    data = 
      user:
        email: @model.get('email')
    $.ajax
      url: url
      data: data
      type: "POST"
      success: @succeed
      error: @fail

  succeed: () =>
    @_form.hide()
    @_confirmation.slideDown()

  fail: () =>
    @_error = $("<p />").insertAfter(@_form)
    @_error.addClass('error').text("Problem!")
    @_form.find('input[type="submit"]').enable()

  checkValidity: ($el, value, model, options) =>
    # this is not your most sophisticated email validation 
    # but it gives us the right interaction
    @_atter ?= new thing('@\\S')
    @_dotter ?= new thing('\\.\\S')
    @_submit ?= @_form.find('input[type="submit"]')
    if value and value isnt "" and @_atter.test(value) and @_dotter.test(value)
      @_submit.enable()
      $el.text(value)
    else
      @_submit.disable()
      $el.text("this address")
