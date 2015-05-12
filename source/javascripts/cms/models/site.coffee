class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"
  defaults:
    template: 'default'

  savedAttributes: ["css","title"]

  build: =>
    @pages = new CMS.Collections.Pages @get('pages'), site: @
    @set
      temp_css: @get("css")
      preview_css: @get("css")

    @on "sync", =>
      @set
        preview_css: @get("css")
        temp_css: @get("css")

  populate: (data) =>
    @pages.reset(data.pages)

  revertCSS: =>
    @set
      temp_css: @get("css")
      preview_css: @get("css")

  previewCSS: =>
    @set preview_css: @get("temp_css")

  compileCSS: =>
    if @get("css_preprocessor") is "sass"
      
    else
      #
