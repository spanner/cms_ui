class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"
  defaults:
    template: 'responsive'
  savedAttributes: ["css", "title", "domain", "template", "header", "footer", "css_preprocessor", "css", "font_css_url", "js_preprocessor", "js"]

  build: =>
    @pages = new CMS.Collections.Pages @get('pages'), site: @
    @nav_pages = new CMS.Collections.NavPages
    @set('css_preprocessor', 'sass') unless @get('css_preprocessor')

  populate: (data) =>
    @pages.reset(data.pages)
    @populateDates(data)
    @populateNavigation()
    @populateCSS()
    @pages.on "change:nav", @populateNavigation
    true
  
  populateNavigation: (e) =>
    @nav_pages.reset(@pages.where(nav: true))
    @touch() if e

  populateCSS: =>
    @set original_css: @get("css")
    @set original_processed_css: @get("processed_css")

  revertCSS: =>
    @set css: @get("original_css")
    @set processed_css: @get("original_processed_css")

  previewCSS: =>
    if @get("css_preprocessor") is "css"
      @set processed_css: @get("css")
    else
      $.ajax("#{_cms.apiUrl()}compile_css",
        type: "POST"
        data:
          css: @get("css")
          css_preprocessor: @get("css_preprocessor") or "sass"
          # css_enclosure: "#page"
      ).done (data) =>
        @set processed_css: data?.css

  # Publish is a specialized form of save that takes a snapshot of the current html state.
  #
  publish: () =>
    $.ajax
      url: @url() + "/publish"
      data:
        rendered_header: @renderHeader()
        rendered_footer: @renderFooter()
      method: "PUT"
      success: @published
      error: @failedToPublish

  published: (response) =>
    @populate(response)

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

