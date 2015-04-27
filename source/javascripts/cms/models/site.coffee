class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"

  build: =>
    @pages = new CMS.Collections.Pages @get("pages"), site: @

  populate: =>
    unless @get("populated")
      @fetch().done (data) =>
        @pages.reset(data.pages)
        @set populated: true
