class CMS.Views.SectionView extends CMS.Views.ItemView
  tagName: "section"
  
  events:
    "click a.delete_section": "deleteSection"
    "click a.add_section": "addSection"
  
  ui:
    built: ".built"
    image_picker: ".cms-image-picker"
    video_picker: ".cms-video-picker"
    admin_menu: ".cms-section-menu"
    editable: ".editable"
    formattable: ".formattable"

  onRender: =>
    @sectionMenu()
    @build() unless @model.get('built_html')
    @ui.editable.attr("contenteditable", "plaintext-only")
    @ui.formattable.attr("contenteditable", "true")
    super

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
    @renderContent()
    @saveBuiltHtml()

  saveBuiltHtml: () =>
    if html = @ui.built.html()
      $(html).find('.cms-control').remove()
      @model.set 'built_html', html, stickitChange: true

  getContentTemplate: () =>
    @getOption('content_template')

  sectionMenu: =>
    @_section_menu = new CMS.Views.SectionAdminMenu
      model: @model
      el: @ui.admin_menu
    @_section_menu.render()

  videoPicker: () =>
    @getVideo()
    @_video_picker = new CMS.Views.VideoPickerLayout
      model: @model.getSite()
      selected: @_video
      el: @ui.video_picker
    @_video_picker.render()
    @_video_picker.on 'selected', @setVideo

  getVideo: =>
    if video_id = @ui.built.find('video').attr('data-video-id')
      @_video = @model.getSite().videos.get(video_id)

  setVideo: (video) =>
    @_video = video
    @build()
    @_video.on "change:url", @build

  imagePicker: () =>
    @getImage()
    @_image_picker = new CMS.Views.ImagePickerLayout
      model: @model.getSite()
      selected: @_image
      el: @ui.image_picker
    @_image_picker.render()
    @_image_picker.on 'selected', @setImage

  getImage: =>
    if image_id = @ui.built.find('img').attr('data-image-id')
      @_image = @model.getSite().images.get(image_id)

  setImage: (image) =>
    @_image = image
    @build()
    @_image.on "change:url", @build

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
    ".caption":
      observe: "caption_html"
      updateMethod: "html"
    ".built":
      observe: "built_html"
      updateMethod: "html"

  onRender: =>
    super
    @imagePicker()

  build: () =>
    @renderContent()
    if @_image
      @ui.built.find('img').attr 'src', @_image.get('preview_url')
      @ui.built.find('img').attr 'data-image-id', @_image.get('id')
    @saveBuiltHtml()



class CMS.Views.BigquoteSection extends CMS.Views.SectionView
  template: "section_types/bigquote"
  tagName: "section"

  bindings:
    ".quoted":
      observe: "main_html"
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



# This one is a pure html editor, with helpers
# html is already defaulted if missing
# --> apply editing controls to existing html
# including a save button.
# nb. saveBuiltHtml will strip out .cms-control
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

  onRender: =>
    super




  build: () =>
    @renderContent()
    @saveBuiltHtml()





# This is an HTML constructor: it holds data properties (image and video)
# and builds new html whenever one of them changes.
#
class CMS.Views.HeroSection extends CMS.Views.SectionView
  template: "section_types/hero"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"
    ".built":
      observe: "built_html"
      updateMethod: "html"

  onRender: =>
    super
    @videoPicker()
    @imagePicker()

  build: () =>
    @renderContent()
    if @_image
      @ui.built.find('img').attr 'src', @_image.get('url')
      @ui.built.find('img').attr 'data-image-id', @_image.get('id')
      @ui.built.find('video').attr 'poster', @_image.get('url')
    if @_video
      @ui.built.find('video').attr 'data-video-id', @_video.get('id')
      @ui.built.find('source').attr 'src', @_video.get('url')
    @saveBuiltHtml()

  getContentTemplate: () =>
    if @_video
      "section_content/video_hero"
    else
      "section_content/image_hero"



class CMS.Views.CarouselSection extends CMS.Views.SectionView
  template: "section_types/carousel"
  tagName: "section"

  events: 
    "click a.add_slide": "addSlide"
    "click .captions p": "setSlide"

  ui:
    carousel: ".carousel"
    captions: ".captions"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".carousel":
      observe: "main_html"
      updateMethod: "html"
    ".captions":
      observe: "secondary_html"
      updateMethod: "html"

  onRender: () =>
    super
    @_slick = @ui.carousel.slick
      autoplay: true
      autoplaySpeed: 10000
    @_slick.on 'beforeChange', @setCaption

  addSlide: () =>
    # pick image
    # add picture block to slides
    # add caption block to captions

  setSlide: (e) =>
    e?.preventDefault()
    if clicked = e.target
      @ui.carousel.slick 'slickGoTo', $(clicked).index()

  setCaption: (e, slick, current_slide, next_slide) =>
    @ui.captions.find('p').removeClass('current').eq(next_slide).addClass('current')

