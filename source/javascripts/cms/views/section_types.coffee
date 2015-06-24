class CMS.Views.SectionView extends CMS.Views.ItemView
  tagName: "section"
  
  events:
    "click a.delete_section": "deleteSection"
    "click a.add_section": "addSection"
  
  ui:
    built: ".built"
    picture: ".picture"
    content: ".content"
    body: ".section_body"
    editable: ".editable"
    formattable: ".formattable"
    image_picker: ".cms-image-picker"
    video_picker: ".cms-video-picker"
    page_picker: ".cms-page-picker"
    admin_menu: ".cms-section-menu"

  onRender: =>
    @sectionMenu()
    if @model.get('built_html')
      @readBuiltHtml()
    else
      @build()
    @ui.editable.attr("contenteditable", "plaintext-only")
    @ui.formattable.attr("contenteditable", "true")
    super

  # returning false from renderContent, eg because there is no content template
  # will short-circuit the building procedure.
  #
  renderContent: () =>
    if template = @getContentTemplate()
      @ui.built.html _cms.render(template, {}, @)
    else
      @ui.built.html ""

  #TODO: this is working gradually towards another render-and-bind,
  # but the big question is what to bind to; content associates are
  # arbitrary and defined by each section type. Perhaps we should push
  # all that through a section content model?
  #
  # For now we just rebuild when selections change.
  #
  build: () =>
    @renderContent() and @saveBuiltHtml()

  readBuiltHtml: () =>
    # noop here
    # this is the place to retrieve data attributes (sort order, page selection)
    # from the built html and restore UI state for onward editing.

  saveBuiltHtml: () =>
    if html = @ui.built.html()
      console.log "saveBuiltHtml", html
      $(html).find('.cms-control').remove()
      @model.set 'built_html', html, stickitChange: true

  getContentTemplate: () =>
    @getOption('content_template')

  imageOrVideo: (size) =>
    @ui.picture.empty()
    image_or_video = new CMS.Views.ImageOrVideo
      model: @model
      el: @ui.picture
      size: size
    image_or_video.render()

  sectionMenu: =>
    @_section_menu = new CMS.Views.SectionAdminMenu
      model: @model
      el: @ui.admin_menu
    @_section_menu.render()

  pagePicker: () =>
    unless @_page_picker
      @_page_picker = new CMS.Views.PagePickerLayout
        model: @model.getSite()
        el: @ui.page_picker
      @_page_picker.render()
      @_page_picker.on 'selected', @setPage

  setPage: (page) =>
    @model.set('page', page)

  videoPicker: () =>
    video_picker = new CMS.Views.VideoPickerLayout
      model: @model
      el: @ui.video_picker
    video_picker.render()
    video_picker.on 'selected', @setVideo

  setVideo: (video) =>
    @model.set('video', video)

  imagePicker: () =>
    image_picker = new CMS.Views.ImagePickerLayout
      model: @model
      el: @ui.image_picker
    image_picker.render()
    image_picker.on 'selected', @setImage

  setImage: (image) =>
    @model.set('image', image)

  deleteSection: () =>
    @model?.destroyReversibly()

  addSection: () =>
    pos = (@model.get('position') ? 0)
    above = @model.collection.filter (s) -> s.get('position') > pos
    _.each above, (s, i) ->
      s.set('position', s.get('position') + 1)
    @model.collection.add
      page_id: @model.get('page_id')
      position: pos + 1
      section_type: 'default'


# Media display subviews are quite elaborate in order to accommodate the various
# image, video and embed tags that might be occupying the same space.
#
#TODO: asset views need refactoring into base classes and mixins.
#
class CMS.Views.AssetView extends CMS.Views.ItemView
  initialize: (options={}) ->
    @_size = options.size ? "full"

  # These views tend to observe the url for change notification
  # but will then call another value to get an image at the right size.
  #
  urlAtSize: (url) =>
    @model.get("#{@_size}_url") ? url


class CMS.Views.Image extends CMS.Views.AssetView
  template: "images/image"
  tagName: "figure"
  className: "image"

  bindings:
    "figcaption":
      observe: "caption"
    "img":
      attributes: [
        name: "src"
        observe: "url"
        onGet: "urlAtSize"
      ]

  onRender: () =>
    super
    @$el.attr('data-image-id', @model.get('id'))


class CMS.Views.Video extends CMS.Views.AssetView
  template: "videos/video"
  tagName: "figure"
  className: "video"

  bindings:
    "figcaption":
      observe: "caption"
    "video":
      observe: "embed_code"
      visible: "untrue"
      attributes: [
        name: "poster"
        observe: "url"
        onGet: "urlAtSize"
      ]
    "img":
      attributes: [
        name: "src"
        observe: "url"
        onGet: "urlAtSize"
      ]
    "source":
      attributes: [
        name: "src"
        observe: "url"
      ]
    ".embed":
      observe: "embed_code"
      visible: true
      updateView: true
      updateMethod: "html"

  onRender: () =>
    super
    @$el.attr('data-video-id', @model.get('id'))


# Initializes with a size and uses the appropriate url.

class CMS.Views.ImageOrVideo extends CMS.Views.ItemView
  template: false

  initialize: (options) ->
    @_size = options.size ? "full"
    @model.on "change:image change:video", @render

  onRender: () =>
    @$el.empty()
    if video = @model.get('video')
      video_viewer = new CMS.Views.Video
        model: video
        size: @_size
      video_viewer.render()
      @$el.append(video_viewer.el)
    else if image = @model.get('image')
      image_viewer = new CMS.Views.Image
        model: image
        size: @_size
      image_viewer.render()
      @$el.append(image_viewer.el)


# displays controls for size, sets url and applies class accordingly.
class CMS.Views.InlineImage extends CMS.Views.Image
  template: "images/inline"
  tagName: "figure"
  className: "image"
  ui:
    style_menu: ".cms-asset-styler"
    
  onRender: () =>
    super
    @_styler = new CMS.Views.ImageStyler
      model: @model
      el: @ui.style_menu
    @_styler.render()
    @_styler.on "styled", @setStyle
    @_styler.on "remove", @removeImage

  setStyle: (style) =>
    console.log "setStyle", style
    @_size = if style is "full" then "full" else "half"
    @$el.removeClass('right left full').addClass(style)
    @$el.parent().trigger 'input'
    # @stickit()

  removeImage: () =>
    @$el.slideUp 'fast', =>
      @remove()


class CMS.Views.InlineVideo extends CMS.Views.Video
  template: "videos/inline"
  tagName: "figure"
  className: "video"
  ui:
    style_menu: ".cms-asset-styler"
    
  onRender: () =>
    super
    @_styler = new CMS.Views.VideoStyler
      model: @model
      el: @ui.style_menu
    @_styler.render()
    @_styler.on "styled", @setStyle
    @_styler.on "remove", @removeVideo

  setStyle: (style) =>
    @_size = if style is "full" then "full" else "half"
    @$el.removeClass('right left full').addClass(style)
    @$el.parent().trigger 'input'
    # @stickit()

  removeVideo: () =>
    parent = @$el.parent()
    @$el.slideUp 'fast', =>
      @remove()
      parent.trigger 'input'


class CMS.Views.AssetInserter extends CMS.Views.ItemView
  template: "sections/asset_inserter"
  tagName: "div"
  className: "cms-asset-inserter"
    
  ui:
    image_picker: ".cms-image-picker"
    video_picker: ".cms-video-picker"
    
  onRender: () =>
    @_p = null
    image_picker = new CMS.Views.ImagePickerLayout
      model: @model
      el: @ui.image_picker
    image_picker.render()
    image_picker.on 'selected', @addImage
    video_picker = new CMS.Views.VideoPickerLayout
      model: @model
      el: @ui.video_picker
    video_picker.render()
    video_picker.on 'selected', @addVideo

  attachTo: ($el) =>
    @_target_el = $el
    @$el.insertAfter @_target_el
    @_target_el.on "click keyup", @followCaret

  followCaret: (e)=>
    selection = @el.ownerDocument.getSelection()
    if !selection or selection.rangeCount is 0
      current = $(e.target)
    else
      range = selection.getRangeAt(0)
      current = $(range.commonAncestorContainer)
    @_p = current.closest('p')
    if @_p.length and _.isBlank(@_p.text())
      @show(@_p.position().top - 10)
    else
      @hide()

  show: (top=0) =>
    @$el.css(top: top).show()

  hide: () =>
    @$el.hide()

  addImage: (image) =>
    inline_img = new CMS.Views.InlineImage
      model: image
    inline_img.render()
    if @_p
      @_p.before inline_img.el
      @_p.remove() if _.isBlank(@_p.text())
    else
      @_target_el.append inline_img.el
    @_target_el.trigger 'input'
    @hide()

  addVideo: (video) =>
    inline_vid = new CMS.Views.InlineVideo
      model: video
    inline_vid.render()
    if @_p
      @_p.before inline_vid.el
      @_p.remove() if _.isBlank(@_p.text())
    else
      @_target_el.append inline_vid.el
    @_target_el.trigger 'input'
    @hide()


class CMS.Views.DefaultSection extends CMS.Views.SectionView
  template: "section_types/default"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
      onSet: "saveHtml"

  onRender: =>
    super
    @assetInserter()
    @ui.body.find('figure.image').each (i, fig) =>
      if img_id = $(fig).data('image-id')
        if image = @model.getSite().images.get(img_id)
          new CMS.Views.InlineImage(model: image, el: fig).render()
    @ui.body.find('figure.video').each (i, fig) =>
      if vid_id = $(fig).data('video-id')
        if video = @model.getSite().videos.get(vid_id)
          new CMS.Views.InlineVideo(model: video, el: fig).render()

  assetInserter: =>
    @_inserter = new CMS.Views.AssetInserter
      model: @model
    @_inserter.render()
    @_inserter.attachTo(@ui.body)

  saveHtml: (html, options) =>
    @_cleaner ?= $('<div>')
    @_cleaner.html(html)
    @_cleaner.find('.cms-controls').remove()
    @_cleaner.find('.editable').removeClass('editable')
    @_cleaner.find('[contenteditable]').removeAttr('contenteditable')
    cleaned = @_cleaner.html()
    cleaned


class CMS.Views.TwocolSection extends CMS.Views.SectionView
  template: "section_types/twocol"
  tagName: "section"

  bindings:
    "h2":
      observe: "title"
    ".col.first":
      observe: "main_html"
      updateMethod: "html"
    ".col.second":
      observe: "secondary_html"
      updateMethod: "html"


class CMS.Views.AsidequoteSection extends CMS.Views.SectionView
  template: "section_types/asidequote"

  bindings:
    "h2.section":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
    ".quoted":
      observe: "secondary_html"
      updateMethod: "text"
    ".speaker":
      observe: "caption_html"
      updateMethod: "text"


class CMS.Views.AsideimageSection extends CMS.Views.SectionView
  template: "section_types/asideimage"
  content_template: "section_content/image_aside"

  bindings:
    "h2.section":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
    "aside .caption":
      observe: "caption_html"
      updateMethod: "html"
    "aside img":
      attributes: [
        name: "src"
        observe: "image"
        onGet: "halfUrl"
      ]

  onRender: =>
    super
    @imageOrVideo('half')
    @imagePicker()
    @videoPicker()


class CMS.Views.BigquoteSection extends CMS.Views.SectionView
  template: "section_types/bigquote"
  tagName: "section"

  bindings:
    ".quoted":
      observe: "secondary_html"
      updateMethod: "text"
    ".speaker":
      observe: "caption_html"
      updateMethod: "text"


class CMS.Views.OnecolSection extends CMS.Views.SectionView
  template: "section_types/onecol"
  tagName: "section"

  bindings:
    ".section_body":
      observe: "main_html"
      updateMethod: "html"


class CMS.Views.BigpictureSection extends CMS.Views.SectionView
  template: "section_types/bigpicture"

  bindings:
    "img":
      attributes: [
        name: "src"
        observe: "image"
        onGet: "heroUrl"
      ]
    ".caption":
      observe: "main_html"
      updateMethod: "html"

  onRender: =>
    super
    @imageOrVideo('hero')
    @imagePicker()
    @videoPicker()


class CMS.Views.HeroSection extends CMS.Views.SectionView
  template: "section_types/hero"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"

  onRender: =>
    super
    @imageOrVideo('hero')
    @videoPicker()
    @imagePicker()
    

# This one is a pure html editor, with helpers
# html is already defaulted if missing
# --> apply editing controls to existing html
# including a save button.
# nb. saveBuiltHtml will strip out any .cms-control
#
class CMS.Views.LinksSection extends CMS.Views.SectionView
  template: "section_types/links"
  content_template: "section_content/link_blocks"

  bindings:
    ".built":
      observe: "built_html"
      updateMethod: "html"

  initialize: ->
    super
    @_pages = new CMS.Collections.Pages

  readBuiltHtml: =>
    @_pages.reset()
    if html = @model.get('built_html')
      site = @model.getSite()
      $(html).find('div.page').each (i, page) =>
        if page_id = page.attr('data-page-id')
          @_pages.add site.pages.get(page_id)

  onRender: =>
    super
    @pagePicker()
    
  setPage: (page) =>
    @_pages?.add(page)
    @build()

  renderContent: =>
    @ui.built.empty()
    @_pages.each (page, i) =>
      container = @$el.find('.built')
      child_view = new CMS.Views.BlockPage
        model: page
      page.load().done () ->
        page.setDefaults()
        rendered = child_view.render()
        container.append(child_view.el)


class CMS.Views.ContentsSection extends CMS.Views.SectionView
  template: "section_types/contents"
  content_template: "section_content/link_blocks"

  events:
    "click a.save": "saveBuiltHtml"

  bindings:
    ".built":
      observe: "built_html"
      updateMethod: "html"

  readBuiltHtml: () =>
    # get sort order from an element data attribute
    # @_comparator = (i) -> -i.get('created_at')

  renderContent: =>
    @ui.built.empty()
    for page in @model.getPage().childPages()
      container = @ui.built
      child_view = new CMS.Views.ChildPage
        model: page
      page.load().done () =>
        page.setDefaults()
        rendered = child_view.render()
        console.log "rendered", child_view.$el.html()
        container.append(child_view.el)

