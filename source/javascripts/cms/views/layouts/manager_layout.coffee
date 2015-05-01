class CMS.Views.ManagerLayout extends CMS.Views.LayoutView
  template: "layouts/manager"

  onRender: =>
    @model.whenReady () =>
      @_sites_layout = new CMS.Views.SitesLayout
        el: @$el.find("#sites")
        collection: @model.sites
      @_sites_layout.render()

  show: (site_slug, page_id, section_uid) =>
    @log "⇒ show", site_slug, page_id, section_uid
    @model.whenReady =>
      if site_slug and site = @model.sites.findWhere(slug: site_slug)
        @_sites_layout.show(site, page_id, section_uid)
      else
        @home()

  home: () =>
    # do a default thing
    @log "home"
