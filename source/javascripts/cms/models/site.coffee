class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"
  defaults:
    template: 'responsive'
  savedAttributes: ["css", "title", "domain", "template", "header", "footer", "css_preprocessor", "css", "font_css_url", "js_preprocessor", "js"]

  build: =>
    @pages = new CMS.Collections.Pages @get('pages'), site: @
    @nav_pages = new CMS.Collections.NavPages
    @set('css_preprocessor', 'sass') unless @get('css_preprocessor')
    @on "change:css", @populateCSS
    @pages.on "change:nav", @populateNavigation

  populate: (data) =>
    @pages.reset(data.pages)
    @populateDates(data)
    @populateNavigation()
    true
  
  populateNavigation: (e) =>
    @nav_pages.reset(@pages.where(nav: true))
    @touch() if e

  populateCSS: =>
    @set temp_css: @get("css")
    @compileCSS()

  revertCSS: =>
    @populateCSS()

  previewCSS: =>
    @set preview_css: @get("temp_css")

  compileCSS: =>
    if @get("css_preprocessor") is "css"
      @set preview_css: @get("temp_css")
    else
      $.ajax("#{_cms.apiUrl()}compile_css",
        type: "POST"
        data:
          css: @get("temp_css")
          css_preprocessor: @get("css_preprocessor") or "sass"
      ).done (data) =>
        @set preview_css: data?.css

  # Publish is a specialized form of save.
  #
  publish: () =>
    $.ajax
      url: @url() + "/publish"
      data:
        rendered_header: @renderHeader()
        rendered_footer: @renderFooter()
        rendered_css: @renderCSS()
      method: "PUT"
      success: @published
      error: @failedToPublish

  published: (response) =>
    @set(response)

  renderHeader: () =>
    renderer = new CMS.Views.HeaderRenderer
      model: @
    renderer.render()
    renderer.$el.get(0).outerHTML

  renderFooter: () =>
    renderer = new CMS.Views.FooterRenderer
      model: @
    renderer.render()
    renderer.$el.get(0).outerHTML

