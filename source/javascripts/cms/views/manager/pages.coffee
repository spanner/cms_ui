class CMS.Views.PageBranch extends CMS.Views.ItemView
  template: "pages/branch"
  tagName: "li"
  className: "branch"
    
  events:
    "click a.delete_page": "deletePage"
    "click a.add_page": "addPage"
    "click a.save_page": "savePage"
    "click a.nav": "toggleNav"
    "keydown span.slug": "catchControlKeys"

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
    "a.nav":
      classes:
        selected: "nav"
    ":el":
      classes:
        selected: "selected"
        destroyed: "deleted_at"
      attributes: [
        observe: "id"
        name: "class"
        onGet: "liClass"
      ]

  onRender: () =>
    super
    @$el.find('span.slug').get(0).focus() if @model.isNew()

  pageUrl: (path) =>
    "/sites/#{@model.getSite().get "slug"}#{path}"

  pageSlug: ([dir, slug]=[]) =>
    slug or "home"

  liClass: (id) =>
    if id then "branch" else "branch new"
    
  showDescent: (path) =>
    if path is "/"
      ""
    else
      depth = (path.match(/\//g) || []).length
      trail = ''
      if depth > 0
        trail += '<span class="d"></span>' for [1..depth]
        trail += '<span class="a">↳</span>'
      trail

  toggleNav: (e) =>
    e?.preventDefault()
    @model.set "nav", not @model.get("nav")

  addPage: (e) =>
    e?.preventDefault()
    $.newpage = @model.collection.add
      dir: @model.get('path')
    @model.collection.sort()

  savePage: (e) =>
    e?.preventDefault()
    @model.save()
  
  deletePage: (e) =>
    e?.preventDefault()
    if @model.isNew()
      @model.destroy()
    else
      if confirm("You really want to remove the whole #{@model.get('title')} page?")
        @model.destroy()
  
  catchControlKeys: (e) =>
    switch e.keyCode
      when 13 then @savePage(e)
      when 27 then @deletePage(e)



class CMS.Views.PagesTree extends CMS.Views.MenuView
  childView: CMS.Views.PageBranch
  template: "pages/menu"


class CMS.Views.PageControls extends CMS.Views.ItemView
  template: "manager/page_controls"
  
  events:
    "click a.save_page": "savePage"
    "click a.publish_page": "publishPage"

  bindings: 
    "a.save_page":
      observe: "changed"
      visible: true
    "a.publish_page":
      observe: ["changed", "published_at", "updated_at"]
      visible: "ifPublishable"

  savePage: (e) =>
    e?.preventDefault()
    @model.save()
    _cms.vent.trigger('reset')

  ifPublishable: ([changed, published_at, updated_at]=[]) =>
    not published_at or (updated_at > published_at) and not changed
    
  publishPage: (e) =>
    e?.preventDefault()
    published = new CMS.Views.PublishedPage
      model: @model
    published.render()
    debugger


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
      @model.select()

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

