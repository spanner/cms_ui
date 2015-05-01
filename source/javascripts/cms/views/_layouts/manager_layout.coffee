class CMS.Views.ManagerLayout extends Backbone.Marionette.LayoutView
  template: "layouts/manager"

  onRender: =>
    @_editor = new CMS.Views.EditorLayout
      el: @$el.find("#editor")

    @_sites_list = new CMS.Views.SitesList
      el: @$el.find(".cms-sites-list")
      collection: @_user.sites
    @_pages_tree = new CMS.Views.PagesTree
      el: @$el.find(".cms-pages-tree")
    @_sections_list = new CMS.Views.SectionsList
      el: @$el.find(".cms-sections-list")
    @_site_crumb = new CMS.Views.SiteCrumb
      el: @$el.find(".cms-site-crumb")`Ωwa`
    @_page_crumb = new CMS.Views.PageCrumb
      el: @$el.find(".cms-page-crumb")
    @_section_crumb = new CMS.Views.SectionCrumb
      el: @$el.find(".cms-section-crumb")


    @_sites_list.render()
    @_pages_tree.render()
    @_sections_list.render()
    @_site_crumb.render()
    @_page_crumb.render()
    @_page_view.render()
    @_section_crumb.render()


  show: (site_slug, page_id, section_uid) =>
    @model.ready().done () =>
      site = @model.sites.find_where(slug: site_slug)
      # site needs its own loading_promise
      site.load().done =>
        # choose page and section
        # populate editor












  toggleList: (list) =>
    if @[list].$el.css('display') is 'none'
      @_sites_list.hide()
      @_pages_tree.hide()
      @_sections_list.hide()
      @[list].show()
    else
      @[list].hide()

  hideList: (list) =>
    @[list].hide()

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
    @_page = if page_id then @_site?.pages.findWhere(id: parseInt(page_id,10)) else null
    if @_site and !@_page
      @_page = @_site.pages.findWhere(path: "/")
    @_page_crumb.setModel @_page
    @_page_view.setModel @_page
    @_sections_list.setModel @_page

    if !@_page or @_page?.isPopulated()
      @setSection section_id
      @_page_view.render()
    else
      @_page.once "change:populated", =>
        @setSection section_id
        @_sections_list.render()
        @_page_view.render()

  setSection: (section_id) =>
    @_section = if section_id then @_page?.sections.findWhere(id: parseInt(section_id,10)) else null
    @_section_crumb.setModel @_section
