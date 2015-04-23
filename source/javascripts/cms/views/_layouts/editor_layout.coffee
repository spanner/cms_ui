class CMS.Views.EditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/editor"

  routes: =>
    "sites/:site_slug/pages/:page_uid/sections/:section_uid(/)": @setSite
    "sites/:site_slug/pages/:page_uid(/)": @setSite
    "sites/:site_slug(/)": @setSite
    "(/)": @home

  initialize: (options) ->
    @_path = options.path ? ""
    @_router = new CMS.Router
      routes: _.result(this, 'routes')
    @_user = @model.user

  onRender: =>
    @_sites_list = new CMS.Views.SitesList
      collection: @_user.sites

    @_site_crumb = new CMS.Views.SiteCrumb
      el: @$el.find("[data-cms='site-crumb']")

    @_page_crumb = new CMS.Views.PageCrumb
      el: @$el.find("[data-cms='page-crumb']")
    @_page_view = new CMS.Views.Page
      el: @$el.find("[data-cms='output']")

    @_section_crumb = new CMS.Views.SectionCrumb
      el: @$el.find("[data-cms='section-crumb']")

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

  setSite: (site_slug,page_uid,section_uid) =>
    @_site = if site_slug then @_user.sites.findWhere(slug: site_slug) else null
    @_site_crumb.setModel @_site

    @setPage page_uid,section_uid

  setPage: (page_uid,section_uid) =>
    #TODO default to home or index if there's a site but no page
    @_page = if page_uid then @_site?.pages.findWhere(uid: page_uid) else null
    @_page_crumb.setModel @_page
    @_page_view.setModel @_page

    @setSection section_uid      

  setSection: (section_uid) =>
    @_section = if section_uid then @_page?.sections.findWhere(uid: section_uid) else null
    @_section_crumb.setModel @_section    
