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
      visibleFn: "visibleWithSlide"
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
  viewComparator: 'path'

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
    "a.pub":
      observe: ["path", "published_at"]
      onGet: "publishedLink"
      attributes: [
        name: "href"
        observe: ["path", "published_at"]
        onGet: "publishedUrl"
      ]
      classes:
        published: "published_at"
    ".nav_properties":
      observe: "nav"
      visible: true
      visibleFn: "visibleWithSlide"
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

  publishedLink: ([path, published_at]=[]) =>
    @model.publishedUrl(path)

  publishedUrl: ([path, published_at]=[]) =>
    if published_at
      @model.publishedUrl(path)
    else
      '#'


class CMS.Views.PageControls extends CMS.Views.ItemView
  template: "manager/page_controls"
  
  events:
    "click a.save_page": "savePage"
    "click a.publish_page": "publishPage"

  ui:
    confirmation: "span.confirmation"
    save_button: "a.save_page"
    publish_button: "a.publish_page"

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
    @ui.save_button.addClass('waiting')
    @model.save().done () =>
      @ui.save_button.removeClass('waiting')
      @confirm "saved"

  ifPublishable: ([changed, published_at, updated_at]=[]) =>
    not changed and (not published_at or updated_at > published_at)
    
  publishPage: (e) =>
    e?.preventDefault()
    @ui.publish_button.addClass('waiting')
    @model.publish().done () =>
      @ui.publish_button.removeClass('waiting')
      @confirm "published"
  
  confirm: (message) =>
    @ui.confirmation.stop().text("✓ #{message}").css(display: "inline-block").fadeOut(2000)


class CMS.Views.PageAdder extends CMS.Views.ItemView
  template: "manager/page_adder"
  className: "button"
  
  events:
    "click a.add_page": "toggleForm"
    "click a.cancel": "hideForm"
    "click a.save": "savePage"

  ui:
    add_button: "a.add_page"
    form: ".new_page"
    title: "span.title"
    save_button: "a.save"

  bindings: 
    "span.title": 
      observe: "title"
    "span.dir": 
      observe: "dir"
      onGet: "withTrailingSlash"
    "span.slug": 
      observe: "title"
      onGet: "slugifyTitle"
    "a.save":
      observe: "title"
      visible: "ifTitleSet"
      visibleFn: "visibleAsInlineBlock"

  initialize: () ->
    super
    @model = new Backbone.Model
      dir: @options.base_path
      page_type: @options.page_type
      title: ""
      slug: ""
    
  toggleForm: (e) =>
    e?.preventDefault()
    if @$el.hasClass('showing') then @hideForm() else @showForm()

  showForm: (e) =>
    e?.preventDefault()
    @$el.addClass('showing')
    @ui.add_button.addClass('cancel')
    @ui.title.focus()

  hideForm: (e) =>
    e?.preventDefault()
    @$el.removeClass('showing')
    @ui.add_button.removeClass('cancel')
  
  ifTitleSet: (title) =>
    not _.isBlank title
  
  slugifyTitle: (title="") =>
    title.toLowerCase().replace('&nbsp;', ' ').replace(/\W+/g, '-')

  withTrailingSlash: (dir) =>
    dir = dir + "/" unless dir.substr(-1) is "/"

  savePage: =>
    properties = 
      title: @model.get('title')
      dir: @model.get('dir')
      slug: @slugifyTitle(@model.get('title'))
      page_type: @model.get('page_type')
    page = @collection.create properties
    url = "/sites/#{page.getSite().get "slug"}#{page.get('path')}"
    _cms.navigate url

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

  #TODO handle these through an event listener in the UI layout and set a cookie with interface state.
  #
  toggleUI: (e) =>
    e?.preventDefault()
    _cms.vent.trigger('ui.state')

  toggleShelf: (e) =>
    e?.preventDefault()
    _cms.vent.trigger('ui.shelve')

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
    adder: "#page_adder"

  onRender: =>
    @stickit()
    @model.whenLoaded =>
      @_site_manager = new CMS.Views.SiteManagerLayout
        collection: @model.sites
      @getRegion('site').show(@_site_manager)
      #TODO init user/session menu

  setSite: (site) =>
    site.select()
    site.whenLoaded () =>
      @_pages_manager = new CMS.Views.PagesManagerLayout
        collection: site.pages
      @getRegion('pages').show(@_pages_manager)

  setPage: (page) =>
    page.select()
    page.whenLoaded () =>
      @_page_manager = new CMS.Views.PageManagerLayout
        model: page
      @getRegion('page').show(@_page_manager)

      # @_sections_manager = new CMS.Views.SectionsManagerLayout
      #   collection: page.sections
      # @getRegion('sections').show(@_sections_manager)

      @_page_controls = new CMS.Views.PageControls
        model: page
      @getRegion('controls').show(@_page_controls)

      default_page_type = page.getSite().page_types.findWhere(default: true)
      @_page_adder = new CMS.Views.PageAdder
        collection: page.collection
        base_path: page.get('path')
        page_type: default_page_type
      @getRegion('adder').show(@_page_adder)

  setSection: (section) =>
    # hash-observation hooks link here how?
    section.select()
