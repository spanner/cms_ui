class CMS.Views.ListedSite extends CMS.Views.ItemView
  template: "sites/listed"
  tagName: "li"
  className: "item"

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
  template: "sites/menu"
  childView: CMS.Views.ListedSite


class CMS.Views.SitesLayout extends CMS.Views.MenuLayout
  template: "manager/sites"
  menuView: CMS.Views.SitesMenu
  
  bindings: 
    "a.title": "title"

  show: (site_slug, page_path) =>
    if site = @collection.findWhere(slug: site_slug)
      @model = site
      @stickit()
      # @_sites_list.setModel('site')
      _cms._ui.editSite(site)
      @model.whenReady =>
        @_pages_layout = new CMS.Views.PagesLayout
          el: @$el.find("#pages")
          collection: @model.pages
        @_pages_layout.render()
        @_pages_layout.show(page_path)
      @model.load() unless @model.isReady()

