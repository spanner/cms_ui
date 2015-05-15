class CMS.Views.UILayout extends CMS.Views.LayoutView
  template: "layouts/ui"

  events:
    "click #manager_menu a": "toggleSiteEditor"

  ui:
    site: "#site_editor"

  onRender: =>
    @_barrier = new CMS.Views.SessionLayout
      el: @$el.find('#session')
      model: @model
    @_barrier.render()

    @_manager = new CMS.Views.ManagerLayout
      el: @$el.find('#manager')
      model: @model.getUser()
    @_manager.render()

    @ui.toggle = @_manager.$el.find("#manager_menu")

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
  editSite: (site) =>
    @_site_editor_layout = new CMS.Views.SiteEditorLayout
      el: @$el.find("#site_editor")
      model: site
    @_site_editor_layout.render()

  sessionView: (action) =>
    @_barrier.show(action)
  
  homeView: () =>
    @_manager.show()

  toggleSiteEditor: =>
    if @ui.toggle.hasClass("open")
      @ui.toggle.removeClass("open")
      @ui.site.removeClass("open")
    else
      @ui.toggle.addClass("open")
      @ui.site.addClass("open")
