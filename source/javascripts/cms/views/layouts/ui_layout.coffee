class CMS.Views.UILayout extends CMS.Views.LayoutView
  template: "layouts/ui"

  onRender: =>
    @_barrier = new CMS.Views.SessionLayout
      el: @$el.find('#session')
      model: @model
    @_barrier.render()

    @_manager = new CMS.Views.ManagerLayout
      el: @$el.find('#manager')
      model: @model.getUser()
    @_manager.render()

    # TODO the editor needs to get its page from somewhere; probably the session user
    # @_editor = new CMS.Views.EditorLayout
    #   el: @$el.find("#editor")
    # @_editor.render()

  siteView: (site_slug, page_path) =>
    @_manager.show(site_slug, page_path)

  sessionView: (action) =>
    @_barrier.show(action)
  
  homeView: () =>
    @_manager.home()
