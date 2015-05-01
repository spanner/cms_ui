class CMS.Models.Page extends CMS.Model

  build: =>
    @sections = new CMS.Collections.Sections @get('sections'), page: @

  populate: (data) =>
    @sections.reset(data.sections)

  getSite: =>
    @collection.site
