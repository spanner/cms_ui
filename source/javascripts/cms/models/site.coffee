class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"
  defaults:
    template: 'responsive'
  savedAttributes: ["css", "title", "domain", "template", "header", "footer", "sass", "font_css_url", "coffee"]

  build: =>
    @page_types = new CMS.Collections.PageTypes @get('page_types'), site: @
    @pages = new CMS.Collections.Pages @get('pages'), site: @
    @nav_pages = new CMS.Collections.NavPages

  populate: (data) =>
    @pages.reset(data.pages)
    @page_types.reset(data.page_types)
    @populateDates(data)
    @populateNavigation()
    @populateCSS()
    @pages.on "change:nav", @populateNavigation
    true

  populateNavigation: (e) =>
    @nav_pages.reset(@pages.where(nav: true))
    @touch() if e

  #TODO repeat for coffee -> js
  #
  populateCSS: =>
    @set original_sass: @get("sass")
    @set original_css: @get("css")

  revertCSS: =>
    @set sass: @get("original_sass")
    @set css: @get("original_css")

  previewCSS: =>
    $.ajax("#{_cms.apiUrl()}compile_css",
      type: "POST"
      data:
        sass: @get("sass")
    ).done (data) =>
      @set css: data?.css

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
    renderer = new CMS.Views.SiteHeaderRenderer
      model: @
    renderer.render()
    renderer.$el.get(0).outerHTML

  renderFooter: () =>
    renderer = new CMS.Views.SiteFooterRenderer
      model: @
    renderer.render()
    renderer.$el.get(0).outerHTML

