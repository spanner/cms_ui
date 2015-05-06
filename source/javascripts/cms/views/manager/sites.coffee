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
    # we definitely have a collection
    @_sites_list = new CMS.Views.SitesMenu
      el: @$el.find(".menu")
      collection: @collection
    @_sites_list.render()

    # but we don't always have a model
    @model?.whenReady () =>
      @stickit()
      @_pages_layout = new CMS.Views.PagesLayout
        el: @$el.find("#pages")
        collection: @model.pages
      @_pages_layout.render()

  show: (site, path="") =>
    @log "⇒ show", site, path
    @model = site
    @model.load() unless @model.isReady()
    @render()
    @setPagePath(path)
    @_sites_list.hide()

  toggleMenu: =>
    if @_sites_list.$el.css('display') is 'none'
      @_sites_list.show()
    else
      @_sites_list.hide()

  setPagePath: (path) =>
    @log "path", path
    @model?.whenReady =>
      if page = @model.pages.findWhere(path: "/#{path}")
        @_pages_layout.show(page)
