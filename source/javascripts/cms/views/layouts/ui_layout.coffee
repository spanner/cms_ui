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

  siteView: (site_slug, page_path, section_id) =>
    @_manager.show(site_slug, page_path)


  # Callback to load the eventually selected page into the editor.
  #
  editPage: (page) =>
    @_editor = new CMS.Views.EditorLayout
      el: @$el.find("#editor")
      model: page
    @_editor.render()

  # Callback to load the eventually selected site into the stylesheet editor.
  #
  editSiteStyle: (site) =>
    @_styler = new CMS.Views.StylerLayout
      el: @$el.find("#styler")
      model: site
    @_styler.render()

  sessionView: (action) =>
    @_barrier.show(action)
  
  homeView: () =>
    @_manager.show()
