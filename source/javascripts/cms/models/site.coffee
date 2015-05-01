class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"

  build: =>
    @pages = new CMS.Collections.Pages @get('pages'), site: @
    
  populate: (data) =>
    @pages.reset(data.pages)
