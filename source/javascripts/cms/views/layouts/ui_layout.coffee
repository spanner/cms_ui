class CMS.Views.UILayout extends CMS.Views.LayoutView
  template: "layouts/ui"

  regions:
    configuration: '#configuration'
    manager: '#manager'
    editor: '#editor'
    session: '#session_barrier'
    user: '#user_settings'

  #todo: user menu inc logout and preferences

  onRender: =>
    # barrier comes up by default and shows a waiting state. It only remains
    # visible if there is no session yet, or it we route to a management view.
    @_barrier = new CMS.Views.SessionLayout
      model: @model
      el: @$el.find('#session_barrier')
    @_barrier.render()

  sessionView: (action) =>
    @_barrier.show(action)
  
  homeView: () =>
    @siteView()

  siteView: (site_slug, page_path) =>
    @model.whenReady () =>
      user = @model.getUser()
      @setUser(user)
      user.load()
      user.whenReady () =>
        if site = user.sites.findWhere(slug: site_slug)
          @setSite(site)
          site.load() unless site.isReady()
          site.whenReady () =>
            if page = site.pages.findWhere(path: "/#{page_path}")
              @setPage(page)
              page.load()

  setUser: (user) =>
    # we have user object with sites collection
    #TODO init user/session menu
    @_manager = new CMS.Views.ManagerLayout
      model: user
    @getRegion('manager').show @_manager

  setSite: (site) =>
    # we have site object with pages collection
    @_manager.setSite(site)
    @_configurator = new CMS.Views.SiteEditorLayout
      model: site
    @getRegion('configuration').show @_configurator

  setPage: (page) =>
    # we have page object with sections collection
    @_manager.setPage(page)
    @_editor = new CMS.Views.PageEditorLayout
      model: page
    @getRegion('editor').show @_editor
