class CMS.Views.SessionLayout extends CMS.Views.LayoutView
  template: 'layouts/session'

  regions:
    form: "#form"
    menu: "#session_menu"

  onRender: () =>
    @wait()
    @model.whenUserReady @goAway
    if @model.token
      @model.once "change:token", @home
    else
      @home()

  wait: () =>
    @$el.find('.waiter').show()

  unwait: () =>
    @$el.find('.waiter').hide()

  goAway: () =>
    @unwait()
    @getRegion('form').reset()
    # @getRegion('menu').show(new CMS.Views.SessionMenu)

  hide: () =>
    @$el.hide()

  show: (action) =>
    @$el.show()
    switch action
      when "reset" then @showForm('SessionResetForm')
      when "confirm" then @showForm('SessionConfirmationForm')
      when "reconfirm" then @showForm('SessionReconfirmationForm')
      when "repassword" then @showForm('SessionPasswordForm')

  showForm: (klass) =>
    klass = CMS.Views[klass]
    view = new klass(model: @model)
    @unwait()
    @getRegion('form').show(view)
  
  # our standard name for a default action doesn't fit well here.
  home: () =>
    @unwait()
    @showForm('SessionLoginForm') unless @model.userIsReady()
