class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"
  defaults:
    template: 'default'

  savedAttributes: ["css"]

  build: =>
    @pages = new CMS.Collections.Pages @get('pages'), site: @
    @set temp_css: @get("css")
    @set old_css: @get("css")

    @on "sync", =>
      @set old_css: @get("css")

  populate: (data) =>
    @pages.reset(data.pages)

  revertCSS: =>
    @set
      temp_css: @get("old_css")
      css: @get("old_css")

  applyCSS: =>
    @set css: @get("temp_css")
