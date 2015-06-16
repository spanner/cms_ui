class CMS.Models.Page extends CMS.Model
  savedAttributes: ['site_id', 'page_type_id', 'path', 'title', 'introduction', 'nav', 'nav_name', 'nav_position', 'nav_heading']

  defaults:
    nav: false

  build: =>
    @setPageType()
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
    if @page_type and not @sections.length
      for type in @page_type.defaultSectionsList()
        @sections.add
          section_type: type
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
    console.log "setPageType", @get('page_type_id')
    @page_type = @getSite().page_types.get(@get('page_type_id'))

  getSite: =>
    @collection.getSite()

  changedIfAnySectionChanged: (e) =>
    if @sections.findWhere(changed: true)
      @set "changed", true
  
  toJSON: () =>
    json = super
    json.sections = @sections.toJSON()
    json

  # Publish is a special save that sends up our rendered html for composition and saving.
  #
  publish: () =>
    $.ajax
      url: @url() + "/publish"
      data:
        main_html: @render()
      method: "PUT"
      success: @published
      error: @failedToPublish
  
  published: (response) =>
    @set(response)

  failedToPublish: (request) =>
    #...

  render: () =>
    renderer = new CMS.Views.PageRenderer
      model: @
      collection: @sections
    renderer.render()
    renderer.$el.get(0).outerHTML


