class CMS.Models.Page extends CMS.Model
  savedAttributes: ['site_id', 'page_type_id', 'path', 'title', 'introduction', 'link_title', 'precis', 'image_id', 'nav', 'nav_name', 'nav_position', 'nav_heading']

  defaults:
    nav: false

  build: =>
    @belongsTo 'page_type', 'page_type_id', @getSite().page_types
    @belongsTo 'image', 'image_id', @getSite().images

    if @get('path')
      @splitPath()
    else if @get('dir')
      @joinPath()
    @on "change:slug", @joinPath
    @on "change:dir", @joinPath
    @on "sync", @splitPath

    @on "change:nav", @updateSiteNav
    @sections = new CMS.Collections.Sections @get('sections'), page: @
    @sections.on "add reset remove", @markAsChanged
    @sections.on "change", @changedIfAnySectionChanged

  populate: (data) =>
    @sections.reset(data.sections)
    @populateDates(data)
    @set "changed", false
    if !@sections.length and @get('page_type')
      for type in @get('page_type').defaultSectionsList()
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

  published: () =>
    @get('published_at')?

  publishedUrl: () =>
    path = @get('path') + ".html"
    @getSite().publishedUrl(path)
  
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
    renderer.el.innerHTML


  # our child pages have a path that starts with our path then a /, and includes no later /
  childPages: () =>
    path = @get('path')
    path = "" if path is "/"
    escaped_path = path.replace('/', '\/')
    stemmer = new RegExp("^#{escaped_path}\/[^\/]+$", "i")
    pages = @getSite().pages.select (p) ->
      stemmer.test(p.get('path'))

  # our descendants only need to have a path that starts with our path/
  descendantPages: () =>
    path = @get('path')
    path = "" if path is "/"
    escaped_path = path.replace('/', '\/')
    stemmer = new RegExp("^#{escaped_path}\/", "i")
    @getSite().pages.select (p) ->
      stemmer.test(p.get('path'))

  pathDepth: () =>
    path = @get('path')
    depth = 0
    if (path isnt "/") and (matches = path.match(/\//g))
      depth = matches.length
    depth

  loadAndSetDefaults: () =>
    @load().done @setDefaults

  setDefaults: () =>
    unless @get('link_title')
      @set('link_title', @get('title'), stickitChange: true)
    unless @get('precis')
      @set('precis', @get('introduction'), stickitChange: true)
    unless @get('image')
      image = @sections.pluck('image')[0]
      @set('image', image, stickitChange: true)

