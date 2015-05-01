class CMS.Views.SessionLayout extends CMS.Views.LayoutView
  template: 'layouts/session'

  regions:
    form: "#form"

  onRender: () =>
    @wait()
    @model.whenReady @unwait
    @model.whenUserReady @goAway
    @showForm('SessionLoginForm') unless @model.userIsReady()

  wait: () =>
    @$el.find('.loading').show()

  unwait: () =>
    @$el.find('.loading').hide()

  goAway: () =>
    @unwait()
    @getRegion('form').clear()
    
  show: (action) =>
    switch action
      when "reset" then @showForm('SessionResetForm')
      when "confirm" then @showForm('SessionConfirmationForm')
      when "reconfirm" then @showForm('SessionReconfirmationForm')
      when "repassword" then @showForm('SessionPasswordForm')

  showForm: (klass) =>
    klass = CMS.Views[klass]
    @log "showForm", klass
    view = new klass(model: @model)
    @unwait()
    @getRegion('form').show(view)
