class CMS.Views.ManagerLayout extends CMS.Views.LayoutView
  template: "layouts/manager"

  onRender: =>
    @model.whenReady () =>
      @_sites_layout = new CMS.Views.SitesLayout
        el: @$el.find("#sites")
        collection: @model.sites
      @_sites_layout.render()

  show: (site_slug, page_path) =>
    @model.whenReady =>
      if site_slug
        if site = @model.sites.findWhere(slug: site_slug)
          @_sites_layout.show(site, page_path)
      else
        @home()

  home: () =>
    # do a default thing
    @log "home"
