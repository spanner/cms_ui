class CMS.Models.Page extends CMS.Model
  savedAttributes: ['site_id', 'page_type_id', 'path', 'title', 'introduction', 'nav', 'nav_name', 'nav_position', 'nav_heading']

  defaults:
    nav: false

  build: =>
    if @get('path')
      @splitPath()
    else if @get('dir')
      @joinPath()
    @on "change:slug", @joinPath
    @on "change:dir", @joinPath
    @on "change:nav", @updateSiteNav
    @on "change:page_type_id", @setPageType
    @on "sync", @splitPath
    @sections = new CMS.Collections.Sections @get('sections'), page: @
    @sections.on "add reset remove", @markAsChanged
    @sections.on "change", @changedIfAnySectionChanged

  populate: (data) =>
    @sections.reset(data.sections)
    @populateDates(data)
    @set "changed", false
    if @isNew() and not @sections.length
      @sections.add({})
    true

  splitPath: =>
    if path = @get('path')
      parts = path.split(/\/+/g)
      @set "slug", parts.pop()
      @set "dir", parts.join("/")

  joinPath: (model, value, options) =>
    @set 'path', [@get('dir'), @get('slug')].join('/'), options

  parentPage: =>
    @collection.findWhere(path: @get('dir'))
    
  childPages: =>
    @collection.findWhere(dir: @get('path'))

  updateSiteNav: =>
    @getSite()?.populateNavigation()

  setPageType: () =>
    @page_type = @site.page_types.find(@get('page_type_id'))
    unless @sections.length()
      for type in @page_type.default_sections_list
        @sections.add
          section_type: type

  getSite: =>
    @collection.site

  changedIfAnySectionChanged: (e) =>
    if @sections.findWhere(changed: true)
      @set "changed", true
  
  toJSON: () =>
    json = super
    json.sections = @sections.toJSON()
    json

  # Publish is a specialized save.
  #
  publish: () =>
    $.ajax
      url: @url() + "/publish"
      data:
        rendered_head: @renderHead()
        rendered_body: @renderBody()
      method: "PUT"
      success: @published
      error: @failedToPublish
  
  published: (response) =>
    @set(response)
    
  renderHead: () =>
    renderer = new CMS.Views.PageHeadRenderer
      model: @
    renderer.render()
    renderer.$el.get(0).outerHTML

  renderBody: () =>
    renderer = new CMS.Views.PageBodyRenderer
      model: @
      collection: @sections
    renderer.render()
    renderer.$el.get(0).outerHTML


