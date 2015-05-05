class CMS.Views.PageBranch extends CMS.Views.ItemView
  template: "pages/branch"
  bindings:
    "a.title":
      observe: "title"
      attributes: [
        observe: "path"
        name: "href"
        onGet: "pageUrl"
      ]

  pageUrl: (path) =>
    "/sites/#{@model.getSite().get "slug"}#{path}"


class CMS.Views.PagesTree extends CMS.Views.CollectionView
  childView: CMS.Views.PageBranch


class CMS.Views.PagesLayout extends CMS.Views.MenuLayout
  template: "manager/pages"

  events:
    "click > .header a.title": "toggleMenu"

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
    @_pages_tree.hide()
    # sections_layout will be controlled by #links

  toggleMenu: =>
    if @_pages_tree.$el.css('display') isnt 'none'
      @_pages_tree.hide()
    else
      @_pages_tree.show()
