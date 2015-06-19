class CMS.Views.SectionView extends CMS.Views.ItemView
  tagName: "section"
  
  events:
    "click a.delete_section": "deleteSection"
    "click a.add_section": "addSection"
  
  ui:
    built: ".built"
    image_picker: ".cms-image-picker"
    video_picker: ".cms-video-picker"
    picture: ".picture"
    admin_menu: ".cms-section-menu"
    editable: ".editable"
    formattable: ".formattable"

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
    # this is the place to retrieve data attributes (sort order, image selection)
    # from the built html and restore UI state for onward editing.

  saveBuiltHtml: () =>
    if html = @ui.built.html()
      $(html).find('.cms-control').remove()
      @model.set 'built_html', html, stickitChange: true

  getContentTemplate: () =>
    @getOption('content_template')

  imageOrVideo: () =>
    @ui.picture.empty()
    image_or_video = new CMS.Views.ImageOrVideo
      model: @model
      el: @ui.picture
    image_or_video.render()

  sectionMenu: =>
    @_section_menu = new CMS.Views.SectionAdminMenu
      model: @model
      el: @ui.admin_menu
    @_section_menu.render()

  videoPicker: () =>
    video_picker = new CMS.Views.VideoPickerLayout
      model: @model.getSite()
      el: @ui.video_picker
    video_picker.render()
    video_picker.on 'selected', @setVideo

  setVideo: (video) =>
    @model.set('video', video)

  imagePicker: () =>
    image_picker = new CMS.Views.ImagePickerLayout
      model: @model.getSite()
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
class CMS.Views.Image extends CMS.Views.ItemView
  template: "images/image"
  bindings:
    "img":
      attributes: [
        name: "src"
        observe: "url"
      ]


class CMS.Views.Video extends CMS.Views.ItemView
  template: "videos/video"
  className: "videobox"

  bindings:
    "video":
      observe: "embed_code"
      visible: "untrue"
      attributes: [
        name: "poster"
        observe: "preview_url"
      ]
    "img":
      attributes: [
        name: "src"
        observe: "preview_url"
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


class CMS.Views.ImageOrVideo extends CMS.Views.ItemView
  template: false

  initialize: ->
    @model.on "change:image change:video", @render

  onRender: () =>
    @$el.empty()
    if video = @model.get('video')
      video_viewer = new CMS.Views.Video
        model: video
      video_viewer.render()
      @$el.append(video_viewer.el)
    else if image = @model.get('image')
      image_viewer = new CMS.Views.Image
        model: image
      image_viewer.render()
      @$el.append(image_viewer.el)


class CMS.Views.DefaultSection extends CMS.Views.SectionView
  template: "section_types/default"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
    ".section_aside":
      observe: "secondary_html"
      updateMethod: "html"
    ".section_note":
      observe: "caption_html"
      updateMethod: "html"


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
        onGet: "assetUrl"
      ]

  onRender: =>
    super
    @imageOrVideo()
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


class CMS.Views.BigtextSection extends CMS.Views.SectionView
  template: "section_types/bigtext"
  tagName: "section"

  bindings:
    ".section_body":
      observe: "main_html"
      updateMethod: "html"


# This is an HTML constructor: it holds data properties (image and video)
# and builds new html whenever one of them changes.
#
class CMS.Views.BigpictureSection extends CMS.Views.SectionView
  template: "section_types/bigpicture"

  bindings:
    ".caption":
      observe: "main_html"
      updateMethod: "html"

  onRender: =>
    super
    @imageOrVideo()
    @imagePicker()


# This is an HTML constructor: it holds data properties (image and video)
# and builds new html whenever one of them changes.
#
class CMS.Views.HeroSection extends CMS.Views.SectionView
  template: "section_types/hero"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"

  onRender: =>
    super
    @imageOrVideo()
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

  events:
    "click a.save": "saveBuiltHtml"

  bindings:
    ".built":
      observe: "built_html"
      updateMethod: "html"

  # build: () =>
  #   @renderContent()
  #   @saveBuiltHtml()


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
    for page in @model.getPage().childPages()
      container = @$el.find('.built')
      child_view = new CMS.Views.ChildPage
        model: page
      page.load().done () =>
        page.setDefaults()
        rendered = child_view.render()
        console.log "rendered", child_view.$el.html()
        container.append(child_view.el)

