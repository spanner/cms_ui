class CMS.Models.Page extends CMS.Model
  build: =>
    @sections = new CMS.Collections.Sections @get("sections")

  populate: =>
    unless @get("populated")
      @fetch().done (data) =>
        @sections.reset(data.sections)
        @set 'populated', true
