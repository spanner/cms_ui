class CMS.Views.SessionLayout extends Backbone.Marionette.LayoutView
  @mixin 'parental'

  template: 'sessions/layout'
  tagName: "section"

  regions:
    childRegion: "[data-cms='session']"

  onRender: () =>
    unless @model.checking()
      @showChild "SessionLoginForm", 
        model: @model

  routes: () =>
    "reset": @showResetForm
    "confirm": @showConfirmationForm
    "reconfirm": @showReconfirmationForm
    "repassword": @showPasswordForm

  stackit: () =>
    super unless @model.checking()

  showLoginForm: () =>
    @_barrier.unwait()
    @showChild "SessionLoginForm", 
      model: @model

  showResetForm: (path) =>
    @showChild "SessionResetForm", 
      model: @model
      path: path

  showConfirmationForm: (path) =>
    @showChild "SessionConfirmationForm", 
      model: @model
      path: path

  showReconfirmationForm: (path) =>
    @showChild "SessionReconfirmationForm", 
      model: @model
      path: path

  showPasswordForm: (path) =>
    @showChild "SessionPasswordForm", 
      model: @model
      path: path
