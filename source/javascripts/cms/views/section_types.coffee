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
    style_menu: ".cms-style-menu"

  onRender: =>
    @sectionMenu()
    @styleMenu()
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

  build: () =>
    @renderContent() and @saveBuiltHtml()

  readBuiltHtml: () =>
    # noop here
    # this is the place to retrieve data attributes (sort order, page selection)
    # from the built html and restore UI state for onward editing.

  saveBuiltHtml: () =>
    if html = @ui.built.html()
      $(html).find('.cms-control').remove()
      @model.set 'built_html', html, stickitChange: true

  getContentTemplate: () =>
    @getOption('content_template')

  imageOrVideo: (size) =>
    @ui.picture.empty()
    @_image_or_video = new CMS.Views.ImageOrVideo
      model: @model
      el: @ui.picture
      size: size
    @_image_or_video.render()

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
    @model.set('subject_page', page)

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

  styleMenu: () =>
    console.log "styleMenu", @getOption('styleMenuView')
    if style_menu_class = @getOption('styleMenuView')
      @_styler = new style_menu_class
        model: @model
        el: @ui.style_menu
      @_styler.render()
      @_styler.on "styled", @setStyle
  
  setStyle: (style) =>
    @model.set('style', style)

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

  cleanHtml: (html, options) =>
    @_cleaner ?= $('<div>')
    @_cleaner.html(html)
    @_cleaner.find('.cms-controls').remove()
    @_cleaner.find('.editable').removeClass('editable')
    @_cleaner.find('[data-placeholder]').removeAttr('data-placeholder')
    @_cleaner.find('[contenteditable]').removeAttr('contenteditable')
    cleaned = @_cleaner.html()
    cleaned


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

  setSize: (size) =>
    @_size = size
    @stickit()


class CMS.Views.Image extends CMS.Views.AssetView
  template: "images/image"
  tagName: "figure"
  className: "image"

  bindings:
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
      @_video_viewer = new CMS.Views.Video
        model: video
        size: @_size
      @_video_viewer.render()
      @$el.append(@_video_viewer.el)
    else if image = @model.get('image')
      @_image_viewer = new CMS.Views.Image
        model: image
        size: @_size
      @_image_viewer.render()
      @$el.append(@_image_viewer.el)

  setSize: (size) =>
    @_image_viewer?.setSize(size)
    @_video_viewer?.setSize(size)


class CMS.Views.AssetStyler extends CMS.Views.ItemView
  template: "images/styler"
  events:
    "click a.right": "setRight"
    "click a.left": "setLeft"
    "click a.full": "setFull"
    "click a.delete": "removeAsset"

  setRight: () => @trigger "styled", "right"
  setLeft: () => @trigger "styled", "left"
  setFull: () => @trigger "styled", "full"
  removeAsset: () =>@trigger "remove"


class CMS.Views.InlineImage extends CMS.Views.Image
  template: "images/inline"
  tagName: "figure"
  className: "image"
  ui:
    style_menu: ".cms-asset-styler"
    caption: "figcaption"

  onRender: () =>
    super
    @_styler = new CMS.Views.AssetStyler
      model: @model
      el: @ui.style_menu
    @_styler.render()
    @_styler.on "styled", @setStyle
    @_styler.on "remove", @removeImage
    @$el.find('.editable').attr('contenteditable', true)

  setStyle: (style) =>
    @_size = if style is "full" then "full" else "half"
    @$el.removeClass('right left full').addClass(style)
    @$el.parent().trigger 'input'
    # @stickit()

  setCaption: (text) =>
    @ui.caption.text(text)

  removeImage: () =>
    @$el.slideUp 'fast', =>
      @remove()


class CMS.Views.InlineVideo extends CMS.Views.Video
  template: "videos/inline"
  tagName: "figure"
  className: "video"
  ui:
    style_menu: ".cms-asset-styler"
    caption: "figcaption"
    
  onRender: () =>
    super
    @_styler = new CMS.Views.AssetStyler
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
    
  setCaption: (text) =>
    @ui.caption.text(text)

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
      onSet: "cleanHtml"

  onRender: =>
    super
    @assetInserter()
    @ui.body.find('figure.image').each (i, fig) =>
      if img_id = $(fig).data('image-id')
        caption = $(fig).find('figcaption').text()
        if image = @model.getSite().images.get(img_id)
          img = new CMS.Views.InlineImage(model: image, el: fig)
          img.render()
          img.setCaption(caption)
    @ui.body.find('figure.video').each (i, fig) =>
      if vid_id = $(fig).data('video-id')
        caption = $(fig).find('figcaption').text()
        if video = @model.getSite().videos.get(vid_id)
          vid = new CMS.Views.InlineVideo(model: video, el: fig)
          vid.render()
          vid.setCaption(caption)

  assetInserter: =>
    @_inserter = new CMS.Views.AssetInserter
      model: @model
    @_inserter.render()
    @_inserter.attachTo(@ui.body)


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


class CMS.Views.AsideimageStyler extends CMS.Views.ItemView
  template: "section_types/asideimage_styler"
  events:
    "click a.right": "setRight"
    "click a.left": "setLeft"
    "click a.full": "setFull"

  setRight: () => 
    @model.set "style", "right", stickitChange: true
  setLeft: () => 
    @model.set "style", "left", stickitChange: true
  setFull: () => 
    @model.set "style", "full", stickitChange: true


class CMS.Views.AsideimageSection extends CMS.Views.SectionView
  template: "section_types/asideimage"
  content_template: "section_content/image_aside"
  styleMenuView: CMS.Views.AsideimageStyler

  bindings:
    ":el":
      attributes: [
        name: "class"
        observe: "style"
      ]
    "h2.section":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
    "aside .caption":
      observe: "caption_html"
      updateMethod: "html"

  onRender: =>
    @model.set('style', 'right') unless @model.get('style')
    super
    @imageOrVideo('half')
    @imagePicker()
    @videoPicker()
    @model.on "change:style", @setStyleSize

  setStyleSize: (model, style) =>
    size = if style is "full" then "full" else "half"
    @_image_or_video.setSize(size)


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



## Contents block
#
# This is purely an html-builder: it uses a helper collection view to assemble a list of link blocks
# in a given style. The link blocks will probably show editable features that bind to the individual page,
# but the built block in the section view is only built, not bound.
#
class CMS.Views.ChildPage extends CMS.Views.ItemView
  template: "pages/child"
  tagName: "div"
  className: "child-page"
  bindings: 
    "a":
      attributes: [
        name: "href"
        observe: "path"
      ]
    ".title":
      observe: "link_title"
      onGet: "cleanText"
    ".precis":
      observe: "precis"
      updateMethod: "html"

  ui:
    picture: ".picture"

  onRender: =>
    # @fetchAndStick()

  # returns a promise that will be resolved when stick finishes
  fetchAndStick: =>
    @_render_promise = $.Deferred()
    @model.load().then(@stick)
    @_render_promise

  stick: =>
     @model.setDefaults()
     @stickit()
     if image = @model.get('image')
       image_viewer = new CMS.Views.Image
         model: image
         size: 'half'
         el: @ui.picture
       image_viewer.render()
     @_render_promise.resolve(@el)
     console.log "stuck"
     


class CMS.Views.NoChildPages extends Backbone.Marionette.ItemView
  template: "pages/none"


class CMS.Views.PageChildren extends CMS.Views.CollectionView
  tagName: "div"
  className: "child_pages"
  childView: CMS.Views.ChildPage
  
  #TODO: pagination.
  initialize: () ->
    @collection = new CMS.Collections.Pages(@model.childPages())
  
  onRender: () =>
    promises = @children.map (child) ->
      child.fetchAndStick()
    $.when(promises...).done (results...) =>
      @trigger "complete", results


class CMS.Views.ContentsStyler extends CMS.Views.ItemView
  template: "section_types/contents_styler"
  events:
    "click a.previews": "setPreview"
    "click a.blocks": "setBlocks"
    "click a.list": "setList"
    "click a.refresh": "refresh"

  setPreview: () => 
    @model.set "style", "previews", stickitChange: true
  setBlocks: () => 
    @model.set "style", "blocks", stickitChange: true
  setList: () => 
    @model.set "style", "list", stickitChange: true
  refresh: () =>
    @trigger "refresh"


class CMS.Views.ContentsSection extends CMS.Views.SectionView
  template: "section_types/contents"
  styleMenuView: CMS.Views.ContentsStyler

  bindings:
    ":el":
      attributes: [
        name: "class"
        observe: "style"
      ]
    ".built":
      observe: "built_html"
      updateMethod: "html"
    "h2.title":
      observe: "title"
      updateMethod: "html"

  onRender: () =>
    super
    @pagePicker()
    @_styler.on "refresh", @build
  
  renderContent: () =>
    @_children_view = new CMS.Views.PageChildren
      model: @model.get('subject_page') or @model.getPage()
    @_children_view.on "complete", () =>
      @saveBuiltHtml()
    @_children_view.render()
    @ui.built.empty()
    @ui.built.append(@_children_view.el)

  setPage: (page) =>
    super
    @build()
