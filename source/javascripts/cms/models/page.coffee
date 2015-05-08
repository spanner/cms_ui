class CMS.Models.Page extends CMS.Model
  savedAttributes: ['title', 'introduction']

  build: =>
    @sections = new CMS.Collections.Sections @get('sections'), page: @

  populate: (data) =>
    @sections.reset(data.sections)
    @sections.on "add reset remove", @markAsChanged
    @sections.on "change", @changedIfAnySectionChanged
    @set "changed", false

  getSite: =>
    @collection.site

  changedIfAnySectionChanged: (e) =>
    # if any section is marked as 'changed', so are we
    if @sections.findWhere(changed: true)
      @set "changed", true

  toJSON: () =>
    json = super
    json.sections = @sections.toJSON()
    json
