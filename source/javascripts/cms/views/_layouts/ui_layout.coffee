class CMS.Views.UILayout extends Backbone.Marionette.LayoutView
  template: "layouts/ui"

  routes: =>
    "sites/:site_uid/pages/:page_uid/sections/:section_uid(/)": @setSite
    "sites/:site_uid/pages/:page_uid(/)": @setSite
    "sites/:site_uid(/)": @setSite
    "(/)": @setSite

  initialize: (options) ->
    @_path = options.path ? ""
    @_router = new CMS.Router
      routes: _.result(this, 'routes')
    _cms.vent.on "auth.change", @onAuthChange

  onAuthChange: =>
    if @model.signedIn()
      @_user = @model.user
      @setPath @_path
    else
      @sessionView()

  onRender: =>
    @_site_view = new CMS.Views.SiteCrumb
      el: @$el.find("[data-cms='site-crumb']")
    @_page_view = new CMS.Views.PageCrumb
      el: @$el.find("[data-cms='page-crumb']")
    @_section_view = new CMS.Views.SectionCrumb
      el: @$el.find("[data-cms='section-crumb']")

    @_site_view.render()
    @_page_view.render()
    @_section_view.render()


  setPath: (path) =>
    @_path = path ? ""
    @_router.handle(@_path)

  setSite: (site_uid,page_uid,section_uid) =>
    @_site = if site_uid then @_user?.sites.findWhere(uid: site_uid) else null
    @_site_view.setModel @_site

    @setPage page_uid,section_uid

  setPage: (page_uid,section_uid) =>
    @_page = if page_uid then @_site?.pages.findWhere(uid: page_uid) else null
    @_page_view.setModel @_page

    @setSection section_uid      

  setSection: (section_uid) =>
    @_section = if section_uid then @_page?.sections.findWhere(uid: section_uid) else null
    @_section_view.setModel @_section    

  sessionView: (path) =>
    console.log "TODO: login"
    #
