class CMS.Views.UILayout extends Backbone.Marionette.LayoutView
  @mixin 'parental'
  template: "layouts/ui"

  regions:
    childRegion: ".cms-ui"

  routes: =>
    "session/*path": @sessionView
    "*path": @editorView

  initialize: (options) ->
    @_child = null
    @_path = options.path ? ""
    @_router = new CMS.Router
      routes: _.result(this, 'routes')

  onRender: =>
    @populate()
    _cms.vent.on "auth.change", @populate

  populate: =>
    @_user = @model.user = new CMS.Models.User
      uid: "ca0b3bd7-505c-4249-ae15-e1a21388aeaf"
    @_user.fetch().done () =>
      @setPath @_path

    # if @model.signedIn()
    #   @_user = @model.user
    #   @setPath @_path
    # else
    #   @sessionView()

  setPath: (path) =>
    @_path = path ? ""
    @_router.handle(@_path)

  editorView: (path) =>
    @showChild "EditorLayout",
      path: path
      model: @model

  sessionView: (path) =>
    @showChild "SessionLayout",
      path: path
      model: @model
