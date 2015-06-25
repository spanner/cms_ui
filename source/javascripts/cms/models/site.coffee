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
    @set
      original_sass: data.sass
      original_css: data.css

  previewCSS: =>
    dfd = $.Deferred()
    if @get("sass") isnt @get("original_sass") or @get("css") isnt @get("original_css")
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
    @set
      original_coffee: data.coffee
      original_js: data.js

  previewJS: =>
    dfd = $.Deferred()
    if @get("coffee") isnt @get("original_coffee") or @get("js") isnt @get("original_js")
      $.ajax("#{@url()}/preview_js",
        type: "POST"
        data: 
          coffee: @get("coffee")
      ).done (data) =>
        if errors = data?.errors
          console.error "Coffeescript parsing errors:", errors
        else if @get("js") is data?.site.js
          @trigger "change:js"
        else
          @set data?.site
        dfd.resolve()
    else
      dfd.resolve()

  populateHTML: (data) =>
    @set
      original_haml: data.haml
      original_html: data.html

  previewHTML: =>
    dfd = $.Deferred()
    if @get("haml") isnt @get("original_haml") or @get("html") isnt @get("original_html")
      $.ajax("#{@url()}/preview_html",
        type: "POST"
        data: 
          haml: @get("haml")
      ).done (data) =>
        if errors = data?.errors
          console.error "HAML parsing errors:", errors
        else if @get("html") is data?.site.html
          @trigger "change:html"
        else
          @set data?.site
        dfd.resolve()
    else
      dfd.resolve()

  publishedUrl: (path="") =>
    path = "/#{path}" unless path[0] = '/'
    "#{_cms.config('published_protocol')}://#{@get('slug')}.#{_cms.config('published_domain')}#{path}"

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
      collection: @pages
    renderer.rendered()
  

