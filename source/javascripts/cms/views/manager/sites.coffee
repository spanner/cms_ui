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


class CMS.Views.SitesMenu extends CMS.Views.CollectionView
  childView: CMS.Views.ListedSite
  

class CMS.Views.SitesLayout extends CMS.Views.MenuLayout
  template: "manager/sites"

  onRender: =>
    @model.whenReady () =>
      @stickit()
      @_sites_list = new CMS.Views.SitesMenu
        el: @$el.find(".menu")
      @_sites_list.render()
      @_pages_layout = new CMS.Views.PagesLayout
        el: @$el.find("#pages")
        collection: @model.pages
      @_pages_layout.render()

  show: (site, page_id, section_uid) =>
    @log "⇒ show", site, page_id, section_uid
    @model = site
    @model.whenReady =>
      @render()
      if page_id and page = @model.pages.find(page_id)
        @_pages_layout.show(page, section_uid)
      else
        @home()

  home: () =>
    # do a default thing
    @log "home"
