class CMS.Views.ManagerLayout extends CMS.Views.LayoutView
  template: "layouts/manager"
  regions:
    site: "#site_manager"
    pages: "#pages_manager"
    sections: "#sections_manager"
    controls: "#page_controls"

  onRender: =>
    @stickit()
    @model.whenReady =>
      @_site_manager = new CMS.Views.SiteManagerLayout
        collection: @model.sites
      @getRegion('site').show(@_site_manager)

  setSite: (site) =>
    site.select()
    site.whenReady () =>
      @_pages_manager = new CMS.Views.PagesManagerLayout
        collection: site.pages
      @getRegion('pages').show(@_pages_manager)

  setPage: (page) =>
    page.select()
    page.whenReady () =>
      @_sections_manager = new CMS.Views.SectionsManagerLayout
        collection: page.sections
      @getRegion('sections').show(@_sections_manager)
      @_page_controls = new CMS.Views.PageControls
        model: page
      @getRegion('controls').show(@_page_controls)

  setSection: (section) =>
    # hash-observation hooks link here how?
    section.select()
