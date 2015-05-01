class CMS.Views.UILayout extends Backbone.Marionette.LayoutView
  template: "layouts/ui"

  onRender: =>
    @_barrier = new CMS.Views.SessionLayout
      el: @$el.find('#session')
      model: @model
    @_manager = new CMS.Views.ManagerLayout
      el: @$el.find('#manager')
      model: @model.getUser()

  show: (site_slug, page_id, section_uid) =>
    @_manager.show(site_slug, page_id, section_uid)

  session: (action) =>
    @_barrier.show(action)
  
  home: () =>
    console.log "home!"
    @_manager.home()
