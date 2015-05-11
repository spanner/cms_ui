class CMS.Views.PageBranch extends CMS.Views.ItemView
  template: "pages/branch"
  tagName: "li"
  className: "branch"
  bindings:
    "a.title":
      observe: "title"
      updateMethod: "html"
      attributes: [
        observe: "path"
        name: "href"
        onGet: "pageUrl"
      ]

  pageUrl: (path) =>
    "/sites/#{@model.getSite().get "slug"}#{path}"


class CMS.Views.PagesTree extends CMS.Views.MenuView
  childView: CMS.Views.PageBranch
  template: "pages/menu"


class CMS.Views.PageControls extends CMS.Views.ItemView
  template: "manager/page_controls"
  
  events:
    "click a.save": "savePage"

  bindings: 
    "a.save_page":
      observe: "changed"
      visible: true

  savePage: (e) =>
    e.preventDefault() if e
    @model.save()


class CMS.Views.PagesLayout extends CMS.Views.MenuLayout
  template: "manager/pages"
  menuView: CMS.Views.PagesTree

  show: (page_path="") =>
    if page = @collection.findWhere(path: "/#{page_path}")
      @model = page
      $.page = page
      @stickit()

      # well this had better get nicer
      # but by keeping it simple we make it
      # easy to eg. preview / edit / publish
      _cms._ui.editPage(page)
      
      @model.whenReady =>
        @_sections_layout = new CMS.Views.SectionsLayout
          el: @$el.find("#sections")
          collection: @model.sections
        @_sections_layout.render()
        @_page_controls = new CMS.Views.PageControls
          el: @$el.find("#controls")
          model: @model
        @_page_controls.render()
      @model.load() unless @model.isReady()
