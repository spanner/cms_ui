class CMS.Views.UILayout extends CMS.Views.LayoutView
  template: "layouts/ui"

  onRender: =>
    @_manager = new CMS.Views.ManagerLayout
      el: @$el.find('#manager')
      model: @model.getUser()
    @_manager.render()
    @_barrier = new CMS.Views.SessionLayout
      el: @$el.find('#session')
      model: @model
    @_barrier.render()

  siteView: (site_slug, page_id, section_uid) =>
    @_manager.show(site_slug, page_id, section_uid)

  sessionView: (action) =>
    @_barrier.show(action)
  
  homeView: () =>
    @_manager.home()
