class CMS.Models.Site extends CMS.Model
  idAttribute: "slug"
  savedAttributes: ["title", "domain", "template", "haml", "sass", "coffee"]

  build: =>
    @page_types = new CMS.Collections.PageTypes @get('page_types'), site: @
    @pages = new CMS.Collections.Pages @get('pages'), site: @
    @images = new CMS.Collections.Images @get('images'), site: @
    @videos = new CMS.Collections.Videos @get('videos'), site: @
    @nav_pages = new CMS.Collections.NavPages

  populate: (data) =>
    @page_types.reset(data.page_types)
    @pages.reset(data.pages)
    @populateDates(data)
    @populateCSS(data)
    @populateJS(data)
    @populateHTML(data)
    @populateImages()
    @on "change:images", @populateImages
    @populateVideos()
    @on "change:videos", @populateVideos
    @populateNavigation()
    @pages.on "change:nav", @populateNavigation
    true

  populateImages: =>
    @images.reset @get("images")

  populateVideos: =>
    @videos.reset @get("videos")

  populateNavigation: (e) =>
    @nav_pages.reset(@pages.where(nav: true))
    @touch() if e

  populateCSS: (data) =>
    @set original_sass: data.sass

  previewCSS: =>
    dfd = $.Deferred()
    if @get("sass") isnt @get("original_sass")
      $.ajax("#{@url()}/preview_css",
        type: "POST"
        data:
          sass: @get("sass")
      ).done (data) =>
        if errors = data?.errors
          console.error "SASS parsing errors:", errors
        @set data?.site
        dfd.resolve()
    else
      dfd.resolve()

  populateJS: (data) =>
    @set original_coffee: data.coffee

  previewJS: =>
    dfd = $.Deferred()
    if @get("coffee") isnt @get("original_coffee")
      $.ajax("#{@url()}/preview_js",
        type: "POST"
        data: 
          coffee: @get("coffee")
      ).done (data) =>
        if errors = data?.errors
          console.error "Coffeescript parsing errors:", errors
        @set data?.site
        dfd.resolve()
    else
      dfd.resolve()

  populateHTML: (data) =>
    @set original_haml: data.haml

  previewHTML: =>
    dfd = $.Deferred()
    if @get("haml") isnt @get("original_haml")
      $.ajax("#{@url()}/preview_html",
        type: "POST"
        data: 
          haml: @get("haml")
      ).done (data) =>
        if errors = data?.errors
          console.error "HAML parsing errors:", errors
        @set data?.site
        dfd.resolve()
    else
      dfd.resolve()

  getWrapper: () =>
    if html = @get('html')
      $(html)
    else
      $("<html><head><title /></head><body><main /></body></html>")

  # Publish is a special save that sends up a snapshot of the current state of our html parts.
  #
  publish: () =>
    $.ajax
      url: @url() + "/publish"
      method: "PUT"
      data:
        nav_html: @renderNavigation()
      success: @published
      error: @failedToPublish

  published: (response) =>
    @populate(response)

  failedToPublish: (request) =>
    #...

  renderNavigation: () =>
    renderer = new CMS.Views.SiteNavigationRenderer
      model: @
      collection: @sections
    renderer.render()
    renderer.$el.get(0).outerHTML

