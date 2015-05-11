class CMS.Views.PageBranch extends CMS.Views.ItemView
  template: "pages/branch"
  tagName: "li"
  className: "branch"
    
  events:
    "click a.add_page": "addPage"
    "click a.save_page": "savePage"

  bindings:
    "span.descent":
      observe: "path"
      onGet: "showDescent"
      updateMethod: "html"
    "a.add_page":
      observe: "id"
      visible: true
      visibleFn: "visibleAsInlineBlock"
    "a.save_page":
      observe: "id"
      visible: "untrue"
      visibleFn: "visibleAsInlineBlock"
    "span.slug":
      observe: "slug"
    "a.title":
      observe: ["dir", "slug"]
      onGet: "pageSlug"
      attributes: [
        name: "href"
        observe: "path"
        onGet: "pageUrl"
      ,
        name: "title"
        observe: "title"
      ]
    ":el":
      attributes: [
        observe: "id"
        name: "class"
        onGet: "liClass"
      ]

  pageUrl: (path) =>
    "/sites/#{@model.getSite().get "slug"}#{path}"

  pageSlug: ([dir, slug]=[]) =>
    slug or "home"

  liClass: (id) =>
    if id then "branch" else "branch new"
    
  showDescent: (path) =>
    depth = (path.match(/\//g) || []).length
    trail = ''
    if depth > 0
      trail += '<span class="d"></span>' for [1..depth]
      trail += '<span class="a">↳</span>'
    trail
    
  addPage: (e) =>
    e.preventDefault() if e
    $.newpage = @model.collection.add
      dir: @model.get('path')
    @model.collection.sort()

  savePage: (e) =>
    e.preventDefault() if e
    @model.save()


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
    _cms.vent.trigger('reset')


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
