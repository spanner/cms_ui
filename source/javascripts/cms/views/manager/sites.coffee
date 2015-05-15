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


class CMS.Views.SiteControls extends CMS.Views.ItemView
  template: "manager/site_controls"
  
  events:
    "click a.save_site": "saveSite"
    "click a.publish_site": "publishSite"

  bindings: 
    "a.save_site":
      observe: "changed"
      visible: true
    "a.publish_site":
      observe: ["changed", "published_at", "updated_at"]
      visible: "ifPublishable"

  saveSite: (e) =>
    e?.preventDefault()
    @model.save()

  ifPublishable: ([changed, published_at, updated_at]=[]) =>
    not changed and (not published_at or updated_at > published_at)
    
  publishSite: (e) =>
    e?.preventDefault()
    console.log "pubslih!"


class CMS.Views.SitesLayout extends CMS.Views.MenuLayout
  template: "manager/sites"
  menuView: CMS.Views.SitesMenu
  bindings: 
    "a.title": "title"

  show: (site_slug, page_path) =>
    if site = @collection.findWhere(slug: site_slug)
      @model = site
      @stickit()
      _cms._ui.editSite(site)
      
      @model.load() unless @model.isReady()

      @model.whenReady =>
        # @_site_controls = new CMS.Views.SiteControls
        #   model: @model
        #   el: $("#site_controls")
        # @_site_controls.render()
        @_pages_layout = new CMS.Views.PagesLayout
          el: @$el.find("#pages")
          collection: @model.pages
        @_pages_layout.render()
        @_pages_layout.show(page_path)


