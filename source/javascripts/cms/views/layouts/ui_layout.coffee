class CMS.Views.UILayout extends CMS.Views.LayoutView
  template: "layouts/ui"

  events:
    "click #manager_menu a": "toggleStyler"

  onRender: =>
    @_barrier = new CMS.Views.SessionLayout
      el: @$el.find('#session')
      model: @model
    @_barrier.render()

    @_manager = new CMS.Views.ManagerLayout
      el: @$el.find('#manager')
      model: @model.getUser()
    @_manager.render()

    @_css_el = @$el.find("#css")
    @_toggle_el = @$el.find("#manager_menu")

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
    @_css_layout = new CMS.Views.CSSLayout
      el: @$el.find("#css")
      model: site
    @_css_layout.render()

  sessionView: (action) =>
    @_barrier.show(action)
  
  homeView: () =>
    @_manager.show()

  toggleStyler: =>
    if @_toggle_el.hasClass("open")
      @_toggle_el.removeClass("open")
      @_css_el.removeClass("open")
    else
      @_toggle_el.addClass("open")
      @_css_el.addClass("open")
