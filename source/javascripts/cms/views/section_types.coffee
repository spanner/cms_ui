class CMS.Views.SectionView extends CMS.Views.ItemView
  tagName: "section"

  ui:
    built: ".built"
    image_picker: ".cms-image-picker"
    video_picker: ".cms-video-picker"
    admin_menu: ".cms-section-menu"

  onRender: =>
    @sectionMenu()
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
    # modify template-generated content using UI-selected values

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
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".col.first":
      observe: "main_html"
      updateMethod: "html"
    ".col.second":
      observe: "secondary_html"
      updateMethod: "html"


class CMS.Views.AsidedSection extends CMS.Views.SectionView
  template: "section_types/asided"
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


class CMS.Views.BigquoteSection extends CMS.Views.SectionView
  template: "section_types/bigquote"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".quoted":
      observe: "main_html"
      updateMethod: "text"
    ".speaker":
      observe: "secondary_html"
      updateMethod: "text"


class CMS.Views.BigtextSection extends CMS.Views.SectionView
  template: "section_types/bigtext"
  tagName: "section"

  bindings:
    ".section_body":
      observe: "main_html"
      updateMethod: "html"


class CMS.Views.GridSection extends CMS.Views.SectionView
  template: "section_types/grid"
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


# class CMS.Models.HeroContent extends Backbone.Model
#   # has an image and a video
#
# class CMS.Models.HeroContentView extends Backbone.Marionette.ItemView
#   template: () =>
#     @model.get('built_html')
#
#   bindings:
#

class CMS.Views.HeroSection extends CMS.Views.SectionView
  template: "section_types/hero"
  content_template: "section_content/hero"

  bindings:
    "h1":
      observe: "title"
    ".built":
      observe: "built_html"
      updateMethod: "html"

  onRender: =>
    super
    @videoPicker()
    @imagePicker()

  build: () =>
    super
    if @_image
      @ui.built.find('img').attr 'src', @_image.get('url')
      @ui.built.find('img').attr 'data-image-id', @_image.get('id')
      @ui.built.find('video').attr 'poster', @_image.get('url')
    if @_video
      @ui.built.find('video').attr 'data-video-id', @_video.get('id')
      @ui.built.find('source').attr 'src', @_video.get('url')
    @model.set 'built_html', @ui.built.html(), stickitChange: true

  getContentTemplate: () =>
    if @_video
      "section_content/video_hero"
    else if @_image
      "section_content/image_hero"
    else
      ""



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

