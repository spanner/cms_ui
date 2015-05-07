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
    @_editor = new CMS.Views.EditorLayout
      el: @$el.find("#editor")
      model: @model.getUser()
    @_editor.render()

    @_styler = new CMS.Views.StylerLayout
      el: @$el.find("#styler")
      model: @model.getUser()

  siteView: (site_slug, page_path, oth) =>
    @_manager.show(site_slug, page_path)
    @_editor.show(site_slug, page_path)
    @_styler.show(site_slug)

  sessionView: (action) =>
    @_barrier.show(action)

  homeView: =>
    @_manager.home()

