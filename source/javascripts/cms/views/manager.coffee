class CMS.Views.PageBranch extends CMS.Views.ItemView
  template: "pages/branch"
  tagName: "li"
  className: "branch"
  
  ui:
    descent: "span.descent"
    shower: "a.shower"
    link: "a.title"
    controls: "span.controls"
    ifnew: ".ifnew"
    ifold: ".ifold"

  events:
    "click a.delete_page": "deletePage"
    "click a.add_page": "addPage"
    "click a.save_page": "savePage"
    "click a.shower": "toggleChildren"
    "click a.nav": "toggleNav"
    "keydown span.slug": "catchControlKeys"

  bindings:
    ":el":
      classes:
        selected: "selected"
        destroyed: "deleted_at"
        changed: "changed"
        hidden: "hide_in_nav"
      attributes: [
        observe: "id"
        name: "class"
        onGet: "liClass"
      ]
    "span.descent":
      observe: "path"
      onGet: "showDescent"
      updateMethod: "html"
    "a.shower":
      observe: "child_count"
      onGet: "showerState"
    "a.add_page":
      observe: ["id", "changed"]
      visible: "thisButNotThat"
      visibleFn: "visibleAsInlineBlock"
    "a.save_page":
      observe: ["changed", "id"]
      visible: "thisOrNotThat"
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
    ".published":
      observe: "published_at"
      visible: true
      visibleFn: "slideVisibility"
    "a.pub":
      attributes: [
        name: "href"
        observe: "path"
        onGet: "publishedUrl"
      ]
    "a.nav":
      classes:
        selected: "nav"
    ".ifnew":
      observe: 'id'
      visible: "untrue"
    ".unlessnew":
      observe: 'id'
      visible: true
    "select.page_type":
      observe: 'page_type_id'
      selectOptions: 
        collection: "this.site.page_types"
        labelPath: 'title'
        valuePath: 'id'
        defaultOption:
          label: 'Page type...'

  initialize: () =>
    @site = @model.getSite()
    # cascade hide status so that hiding a whole branch works
    @model.on "change:hide_in_nav", @resetHiding
    super

  onRender: () =>
    @model.set "child_count", @model.childPages().length
    @hideDescendants() if @model.pathDepth() > 2
    super
    @$el.find('span.slug').get(0).focus() if @model.isNew()

  pageUrl: (path) =>
    "/sites/#{@model.getSite().get "slug"}#{path}"

  pageSlug: ([dir, slug]=[]) =>
    _.truncate(slug or "Home", 40)

  pageTypeName: (page_type_id) =>
    if page_type = @model.getSite().page_types.get(page_type_id)
      page_type.get('title')
    else
      "page type..."

  liClass: (id) =>
    if id then "branch" else "branch new"
  
  # The _children_hidden view property tracks the hide_in_nav model property
  # so that collapsed status cascades down a branch of the page tree and 
  # each branch displays the right expansion arrow when we reopen.
  resetHiding: (value) =>
    @_children_hidden = value
    @stickit()

  showerState: (children) =>
    if children
      if @_children_hidden then "▸ " else "▾ "
    else
      "↳ "
    
  # toggleChildren controls the visibility in navigation of the descendants of this page;
  # that is, of any page whose path starts with our path.
  # You can specify a state (true for hidden, false for visible). If no argument is given,
  # we flip the existing state.
  #
  # In order to mimic tree behaviour, we close all descendant pages but open only our
  # immediate children.
  #
  toggleChildren: (e) =>
    if @_children_hidden
      @showChildren()
    else
      @hideDescendants()
    @stickit()
    
  hideDescendants: () =>
    _.each @model.descendantPages(), (page) -> page.set("hide_in_nav", true)
    @_children_hidden = true

  showChildren: () =>
    _.each @model.childPages(), (page) -> page.set("hide_in_nav", false)
    @_children_hidden = false

  toggleNav: (e) =>
    e?.preventDefault()
    @model.save
      nav: not @model.get("nav")

  addPage: (e) =>
    e?.preventDefault()
    $.a = @model.collection.add
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

  publishedUrl: (path) =>
    @model.publishedUrl(path)


class CMS.Views.PagesTree extends CMS.Views.MenuView
  childView: CMS.Views.PageBranch
  template: "pages/menu"

  initialize: () ->
    super
    @prepareVisibility()

  prepareVisibility: =>
    # @collection.each (page) =>
    #   page.set "hide_in_nav", @page.depth > 3 and @page.child_count > 3

  addItem: =>
    @collection.add
      dir: "/"


class CMS.Views.PagePropertiesMenu extends CMS.Views.MenuView
  template: "pages/properties"

  events:
    "click a.nav": "toggleNav"

  bindings:
    "span.title":
      observe: "title"
    "span.dir":
      observe: "dir"
      onGet: "rootedDir"
    "span.path":
      observe: "path"
    "input.nav":
      observe: "nav"
    ".published":
      observe: "published_at"
      visible: true
      visibleFn: "slideVisibility"
    "a.pub":
      observe: "path"
      onGet: "publishedUrl"
      attributes: [
        name: "href"
        observe: "path"
        onGet: "publishedUrl"
      ]
    ".nav_properties":
      observe: "nav"
      visible: true
      visibleFn: "slideVisibility"
    "span.nav_name":
      observe: "nav_name"
    "span.nav_heading":
      observe: "nav_heading"
    "span.nav_position":
      observe: "nav_position"
    "span.link_title":
      observe: "link_title"
    "a.nav":
      classes:
        selected: "nav"
    "select.page_type":
      observe: 'page_type_id'
      selectOptions: 
        collection: "this.site.page_types"
        labelPath: 'title'
        valuePath: 'id'
        defaultOption:
          label: 'Page type...'

  initialize: =>
    @site = @model.getSite()

  toggleNav: (e) =>
    e?.preventDefault()
    @model.save
      nav: not @model.get("nav")

  rootedDir: (value) =>
    "#{value}/"

  publishedUrl: (path) =>
    @model.publishedUrl(path)


class CMS.Views.PageControls extends CMS.Views.ItemView
  template: "manager/page_controls"
  
  events:
    "click a.save_page": "savePage"
    "click a.publish_page": "publishPage"

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



class CMS.Views.PageManagerLayout extends CMS.Views.MenuLayout
  template: "manager/page"
  menuView: CMS.Views.PagePropertiesMenu


class CMS.Views.PagesManagerLayout extends CMS.Views.MenuLayout
  template: "manager/pages"
  menuView: CMS.Views.PagesTree

  bindings:
    'a.cms-menu-head':
      observe: "path"
      onGet: "pathOrHome"

  initialize: ->
    super
    @collection.on "change:selected", @render

  remove: =>
    @collection.off "change:selected", @render
    super

  onRender: =>
    super
    @model = @collection?.findWhere(selected: true)
    @stickit() if @model

  pathOrHome: (path) =>
    if !path or path is "/"
      "Home"
    else
      _.truncate path, 28



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
    page: "#page_manager"
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
      @_page_manager = new CMS.Views.PageManagerLayout
        model: page
      @getRegion('page').show(@_page_manager)

      # @_sections_manager = new CMS.Views.SectionsManagerLayout
      #   collection: page.sections
      # @getRegion('sections').show(@_sections_manager)

      @_page_controls = new CMS.Views.PageControls
        model: page
      @getRegion('controls').show(@_page_controls)

  setSection: (section) =>
    # hash-observation hooks link here how?
    section.select()
