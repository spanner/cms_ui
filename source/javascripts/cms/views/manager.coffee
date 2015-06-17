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
      observe: ["id", "changed"]
      visible: "thisAndNotThat"
      visibleFn: "visibleAsInlineBlock"
    "a.save_page":
      observe: ["changed", "id"]
      visible: "thisOrNotThat"
      visibleFn: "visibleAsInlineBlock"
    "span.slug":
      observe: "slug"
    "span.page_type":
      observe: 'page_type_id'
      onGet: 'pageTypeName'
    "select.page_type":
      observe: 'page_type_id'
      selectOptions: 
        collection: "this.site.page_types"
        labelPath: 'title'
        valuePath: 'id'
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
        changed: "changed"
      attributes: [
        observe: "id"
        name: "class"
        onGet: "liClass"
      ]
    ".ifnew":
      observe: 'id'
      visible: "untrue"
    ".unlessnew":
      observe: 'id'
      visible: true
  
  initialize: () =>
    @site = @model.getSite()
    super

  onRender: () =>
    super
    @$el.find('span.slug').get(0).focus() if @model.isNew()

  pageUrl: (path) =>
    "/sites/#{@model.getSite().get "slug"}#{path}"

  pageSlug: ([dir, slug]=[]) =>
    slug or "Home"

  pageTypeName: (page_type_id) =>
    if page_type = @model.getSite().page_types.get(page_type_id)
      page_type.get('title')
    else
      "page type..."

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
    @model.save
      nav: not @model.get("nav")

  addPage: (e) =>
    e?.preventDefault()
    @model.collection.add
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

  addItem: =>
    @collection.add
      dir: "/"


class CMS.Views.PageControls extends CMS.Views.ItemView
  template: "manager/page_controls"
  
  events:
    "click a.save_page": "savePage"
    "click a.publish_page": "publishPage"
    "click a.preview": "togglePreview"

  ui:
    confirmation: "span.confirmation"

  bindings: 
    "a.save_page":
      observe: "changed"
      visible: true
      visibleFn: "visibleAsInlineBlock"
    "a.publish_page":
      observe: ["changed", "published_at", "updated_at"]
      visible: "ifPublishable"
      visibleFn: "visibleAsInlineBlock"

  savePage: (e) =>
    console.log "savePage"
    e?.preventDefault()
    @model.save().done () =>
      @confirm "saved"

  ifPublishable: ([changed, published_at, updated_at]=[]) =>
    not changed and (not published_at or updated_at > published_at)
    
  publishPage: (e) =>
    e?.preventDefault()
    @model.publish().done () =>
      @confirm "published"
  
  confirm: (message) =>
    @ui.confirmation.stop().text("✓ #{message}").css(display: "inline-block").fadeOut(2000)

  togglePreview: (e) =>
    e?.preventDefault()
    $('#cms-ui').toggleClass('previewing')
    $('iframe').contents().find('body').toggleClass('previewing')


class CMS.Views.ListedSection extends  CMS.Views.ItemView
  template: "sections/listed"
  tagName: "li"
  className: "item"

  events:
    "click a.title": "select"
    "click a.delete_section": "deleteSection"
    "click a.add_section": "addSection"

  bindings:
    ":el":
      classes:
        selected: "selected"
        destroyed: "deleted_at"
    "a.title":
      observe: ["title", "section_type"]
      onGet: "titleOrType"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "sectionUrl"
      ]

  onRender: () =>
    @stickit()
    @model.select() if window.location.hash is @sectionUrl(@model.get('id'))

  deleteSection: =>
    @model?.destroyReversibly()

  addSection: =>
    pos = (@model.get('position') ? 0)
    above = @model.collection.filter (s) -> s.get('position') > pos
    _.each above, (s, i) ->
      s.set('position', s.get('position') + 1)
    @model.collection.add
      title: "New section"
      page_id: @model.get('page_id')
      position: pos + 1

  select: (e) =>
    e?.preventDefault()
    @model.select()

  sectionUrl: (id) =>
    "#section_#{id}"

  sectionName: (title) =>
    label = title || "New section"
    if label.length > 38
      label = label.substr(0, 36) + "..."
    label

  titleOrType: ([title, section_type]=[]) =>
    _.stripTags(title or section_type).replace(/&nbsp;/g, ' ').replace(/(\r|\n)+/gm, " ")

class CMS.Views.SectionsList extends CMS.Views.MenuView
  template: "sections/menu"
  childView: CMS.Views.ListedSection

  addItem: =>
    top_pos = @collection.last()?.get('position') ? 0
    @collection.add
      title: "New section"
      page_id: @collection.page.id
      position: top_pos + 1
    @collection.sort()


class CMS.Views.SectionsManagerLayout extends CMS.Views.MenuLayout
  template: "manager/sections"
  menuView: CMS.Views.SectionsList

  bindings:
    '.header a.title':
      observe: ["title", "section_type"]
      onGet: "titleOrType"

  titleOrType: ([title, section_type]=[]) =>
    _.stripTags(title or section_type).replace(/&nbsp;/g, ' ')


class CMS.Views.PagesManagerLayout extends CMS.Views.MenuLayout
  template: "manager/pages"
  menuView: CMS.Views.PagesTree

  bindings:
    '.header a.title':
      observe: "slug"
      onGet: "slugOrHome"

  slugOrHome: (slug) =>
    slug or "Home"


class CMS.Views.SiteManagerLayout extends CMS.Views.MenuLayout
  template: "manager/site"

  events:
    "click a.shelf": "toggleShelf"
    "click a.ui": "toggleUI"

  bindings:
    'a.shelf':
      attributes: [
        name: "class"
        observe: ["changed", "published_at", "updated_at"]
        onGet: "siteStatus"
      ]

  showing: =>
    showing = $('#cms-ui').hasClass('shelved')
    showing

  #TODO handle these through an event listener in the UI layout and set a cookie with interface state.
  #
  toggleUI: (e) =>
    e?.preventDefault()
    $('#cms-ui').toggleClass('collapsed')

  toggleShelf: (e) =>
    e?.preventDefault()
    $('#cms-ui').toggleClass('shelved')

  siteStatus: ([changed, published_at, updated_at]=[]) =>
    if changed
      "save_me"
    else if (updated_at > published_at)
      "publish_me"
    else
      ""


class CMS.Views.ManagerLayout extends CMS.Views.LayoutView
  template: "layouts/manager"
  regions:
    site: "#site_manager"
    pages: "#pages_manager"
    sections: "#sections_manager"
    controls: "#page_controls"

  onRender: =>
    @stickit()
    @model.whenReady =>
      @_site_manager = new CMS.Views.SiteManagerLayout
        collection: @model.sites
      @getRegion('site').show(@_site_manager)
      #TODO init user/session menu

  setSite: (site) =>
    site.select()
    site.whenReady () =>
      @_pages_manager = new CMS.Views.PagesManagerLayout
        collection: site.pages
      @getRegion('pages').show(@_pages_manager)

  setPage: (page) =>
    page.select()
    page.whenReady () =>
      @_sections_manager = new CMS.Views.SectionsManagerLayout
        collection: page.sections
      @getRegion('sections').show(@_sections_manager)
      @_page_controls = new CMS.Views.PageControls
        model: page
      @getRegion('controls').show(@_page_controls)

  setSection: (section) =>
    # hash-observation hooks link here how?
    section.select()
