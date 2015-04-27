class CMS.Views.EditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/editor"

  routes: =>
    "sites/:site_slug/pages/:page_id/sections/:section_uid(/)": @setSite
    "sites/:site_slug/pages/:page_id(/)": @setSite
    "sites/:site_slug(/)": @setSite
    "(/)": @home

  initialize: (options) ->
    @_path = options.path ? ""
    @_router = new CMS.Router
      routes: _.result(this, 'routes')
    @_user = @model.user

  onRender: =>
    @_sites_list = new CMS.Views.SitesList
      el: @$el.find("[data-cms='sites-list']")
      collection: @_user.sites
    @_pages_tree = new CMS.Views.PagesTree
      el: @$el.find("[data-cms='pages-tree']")
    @_sections_list = new CMS.Views.SectionsList
      el: @$el.find("[data-cms='sections-list']")

    @_site_crumb = new CMS.Views.SiteCrumb
      el: @$el.find("[data-cms='site-crumb']")

    @_page_crumb = new CMS.Views.PageCrumb
      el: @$el.find("[data-cms='page-crumb']")
    @_page_view = new CMS.Views.Page
      el: @$el.find("[data-cms='output']")

    @_section_crumb = new CMS.Views.SectionCrumb
      el: @$el.find("[data-cms='section-crumb']")

    @_sites_list.render()
    @_pages_tree.render()
    @_sections_list.render()

    @_site_crumb.render()
    @_page_crumb.render()
    @_page_view.render()
    @_section_crumb.render()

    @setPath @_path

  setPath: (path) =>
    @_path = path ? ""
    @_router.handle(@_path)

  home: =>
    @setSite()

  setSite: (site_slug,page_id,section_id) =>
    @_site = if site_slug then @_user.sites.findWhere(slug: site_slug) else null
    @_site_crumb.setModel @_site
    @_pages_tree.setCollection @_site?.pages
    @_pages_tree.render()

    if !@_site or @_site?.isPopulated()
      @setPage page_id,section_id
      @_pages_tree.render()
    else
      @_site.once "change:populated", =>
        @setPage page_id,section_id
        @_pages_tree.render()

  setPage: (page_id,section_id) =>
    #TODO default to home or index if there's a site but no page
    @_page = if page_id then @_site?.pages.findWhere(id: parseInt(page_id,10)) else null
    if @_site and !@_page
      @_page = @_site.pages.findWhere(path: "/")
    @_page_crumb.setModel @_page
    @_page_view.setModel @_page
    @_sections_list.setCollection @_page?.sections

    if !@_page or @_page?.isPopulated()
      @setSection section_id
    else
      @_page.once "change:populated", =>
        @setSection section_id
        @_sections_list.render()

  setSection: (section_id) =>
    @_section = if section_id then @_page?.sections.findWhere(id: parseInt(section_id,10)) else null
    @_section_crumb.setModel @_section
