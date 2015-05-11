class CMS.Models.Page extends CMS.Model
  savedAttributes: ['title', 'introduction', 'nav', 'nav_heading', 'path', 'site_id']

  build: =>
    if @get('path')
      @splitPath()
    else
      @joinPath()
    @on "change:slug", @joinPath
    @on "change:dir", @joinPath
    @sections = new CMS.Collections.Sections @get('sections'), page: @
    @sections.on "add reset remove", @markAsChanged
    @sections.on "change", @changedIfAnySectionChanged
    
  # when a page is created it is given a stem to which a slug must be added to get the full path.

  populate: (data) =>
    @sections.reset(data.sections)
    @set "changed", false
    
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

  getSite: =>
    @collection.site

  changedIfAnySectionChanged: (e) =>
    if @sections.findWhere(changed: true)
      @set "changed", true

  toJSON: () =>
    json = super
    json.sections = @sections.toJSON()
    json
