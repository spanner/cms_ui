class CMS.Views.UILayout extends CMS.Views.LayoutView
  template: "layouts/ui"

  regions:
    configuration: '#cms-configuration'
    manager: '#cms-manager'
    editor: '#cms-editor'
    # session: '#cms-session-barrier'
    # user: '#cms-user-settings'

  #todo: user menu inc logout and preferences

  onRender: =>
    # barrier comes up by default and shows a waiting state. It only remains
    # visible if there is no session yet, or it we route to a management view.
    @_barrier = new CMS.Views.SessionLayout
      model: @model
      el: @$el.find('#cms-session-barrier')
    @_barrier.render()

  sessionView: (action) =>
    @_barrier.show(action)
  
  homeView: () =>
    @siteView()

  siteView: (site_slug="", page_path="") =>
    @model.whenLoaded () =>
      user = @model.getUser()
      @setUser(user)
      @_barrier.hide()
      # user.load()
      user.whenLoaded () =>
        if site = user.sites.findWhere(slug: site_slug)
          @setSite(site)
          site.load() unless site.isLoaded()
          site.whenLoaded () =>
            @setPage(site, page_path)

  setUser: (user) =>
    # we have user object with sites collection
    @_manager = new CMS.Views.ManagerLayout
      model: user
    @getRegion('manager').show @_manager

  setSite: (site) =>
    # we have site object with pages collection
    @_manager.setSite(site)
    @_configurator = new CMS.Views.SiteEditorLayout
      model: site
    @getRegion('configuration').show @_configurator

  setPage: (site, page_path) =>
    @stopListening site, "change:html change:js"

    if page = site.pages.findWhere(path: "/#{page_path}")
      @_manager.setPage(page)

      @_editor = new CMS.Views.PageEditorLayout
        model: page
        el: @$el.find('#cms-editor')
      @_editor.render()

      @listenTo site, "change:html change:js", () => @setPage(site, page_path)

      page.load()
