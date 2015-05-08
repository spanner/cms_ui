class CMS.Views.ListedSite extends CMS.Views.ItemView
  template: "sites/listed"
  bindings:
    "a.title":
      observe: "title"
      attributes: [
        observe: "slug"
        name: "href"
        onGet: "siteUrl"
      ]

  siteUrl: (slug) =>
    "/sites/#{slug}"


class CMS.Views.SitesMenu extends CMS.Views.MenuView
  childView: CMS.Views.ListedSite


class CMS.Views.SitesLayout extends CMS.Views.MenuLayout
  template: "manager/sites"
  
  bindings: 
    "a.title": "title"

  onRender: (options) =>
    @_sites_list = new CMS.Views.SitesMenu
      el: @$el.find(".menu")
      collection: @collection
    @_sites_list.render()

  show: (site_slug, page_path) =>
    if site = @collection.findWhere(slug: site_slug)
      @model = site
      @stickit()
      # @_sites_list.setModel('site')
      @model.whenReady =>
        @_pages_layout = new CMS.Views.PagesLayout
          el: @$el.find("#pages")
          collection: @model.pages
        @_pages_layout.render()
        @_pages_layout.show(page_path)
      @model.load()

  toggleMenu: =>
    if @_sites_list.$el.css('display') is 'none'
      @_sites_list.show()
    else
      @_sites_list.hide()
