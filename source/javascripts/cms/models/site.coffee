class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"
  defaults:
    template: 'default'

  savedAttributes: ["css","title"]

  build: =>
    @pages = new CMS.Collections.Pages @get('pages'), site: @
    @nav_pages = new CMS.Collections.NavPages
    @on "change:nav", @populateNavigation
    @set
      temp_css: @get("css")
      preview_css: @get("css")
    @on "sync", =>
      @set
        preview_css: @get("css")
        temp_css: @get("css")

  populate: (data) =>
    @pages.reset(data.pages)
    @populateNavigation()
  
  populateNavigation: () =>
    @nav_pages.reset @pages.findWhere(nav: true)

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

  toJSON: () =>
    console.log "Site#toJSON"
    json = super
    json.rendered_header = @renderHeader()
    json.rendered_footer = @renderFooter()
    json

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

