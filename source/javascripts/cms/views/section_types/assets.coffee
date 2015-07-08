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
