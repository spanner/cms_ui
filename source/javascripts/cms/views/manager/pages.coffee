class CMS.Views.PageBranch extends CMS.Views.ItemView
  template: "pages/branch"
  bindings:
    ".header a":
      observe: "title"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "pageUrl"
      ]

  pageUrl: (id) =>
    "/sites/#{@model.getSite().get "slug"}/pages/#{id}"


class CMS.Views.PagesTree extends CMS.Views.CollectionView
  childView: CMS.Views.PageBranch


class CMS.Views.PagesLayout extends CMS.Views.MenuLayout
  template: "manager/pages"

  onRender: =>
    # we definitely have a collection
    @_pages_tree = new CMS.Views.PagesTree
      el: @$el.find(".menu")
      collection: @collection
    @_pages_tree.render()

    # but we don't always have a model
    @model?.whenReady () =>
      @stickit()
      @_sections_layout = new CMS.Views.SectionsLayout
        el: @$el.find("#sections")
        collection: @model.sections
      @_sections_layout.render()

  show: (page) =>
    @log "⇒ show", page
    @model = page
    @model.load()
    @render()
    # sections_layout will be controlled by #links

  home: () =>
    # do a default thing
    @log "home"
