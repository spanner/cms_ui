class CMS.Views.SessionReconfirmationForm extends CMS.Views.ItemView
  template: 'sessions/reconfirmation_form'

  events:
    'submit form': 'request_confirmation'

  bindings:
    "#email": "email"
    "span.email": 
      observe: "email"
      update: "checkValidity"

  initialize: () ->
    @model = SIS.session

  onRender: () =>
    @_form = @$el.find('form')
    @_notes = @$el.find('p.note')
    @_confirmation = @$el.find('.confirmation')
    @stickit()

  request_confirmation: (e) =>
    e.preventDefault()
    @$el.find('.error').remove()
    @_form.find('input[type="submit"]').disable()
    base = _sis.config('api_url')
    $.ajax
      url: "#{base}/users/reconfirm"
      type: "post"
      data:
        user:
          email: @model.get('email')
      success: @succeed
      error: @fail

  succeed: () =>
    @_form.slideUp () =>
      @_confirmation.show()

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
      
