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

  onRender: =>
    @_pages_tree = new CMS.Views.PagesTree
      el: @$el.find(".menu")
      collection: @collection
    @_pages_tree.render()

  show: (page_path="") =>
    console.log "pages show", page_path
    if page = @collection.findWhere(path: "/#{page_path}")
      @model = page
      @stickit()
      # @_pages_tree.setModel('page')
      @model.whenReady =>
        @_sections_layout = new CMS.Views.SectionsLayout
          el: @$el.find("#sections")
          collection: @model.sections
        @_sections_layout.render()
      @model.load()

  toggleMenu: =>
    if @_pages_tree.$el.css('display') isnt 'none'
      @_pages_tree.hide()
    else
      @_pages_tree.show()
