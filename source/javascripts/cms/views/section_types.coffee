class CMS.Views.DefaultSection extends CMS.Views.ItemView
  template: "section_types/default"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".section_body":
      observe: "content"
      updateMethod: "html"
    ".section_aside":
      observe: "aside"
      updateMethod: "html"
    ".section_note":
      observe: "note"
      updateMethod: "html"


class CMS.Views.TwocolSection extends CMS.Views.ItemView
  template: "section_types/twocol"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".col.first":
      observe: "content"
      updateMethod: "html"
    ".col.second":
      observe: "aside"
      updateMethod: "html"


class CMS.Views.AsidedSection extends CMS.Views.ItemView
  template: "section_types/asided"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".section_body":
      observe: "content"
      updateMethod: "html"
    ".section_aside":
      observe: "aside"
      updateMethod: "html"


class CMS.Views.BigquoteSection extends CMS.Views.ItemView
  template: "section_types/bigquote"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".quote":
      observe: "content"
      updateMethod: "text"
    ".speaker":
      observe: "aside"
      updateMethod: "text"


class CMS.Views.BigtextSection extends CMS.Views.ItemView
  template: "section_types/bigtext"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".section_body":
      observe: "content"
      updateMethod: "html"


class CMS.Views.GridSection extends CMS.Views.ItemView
  template: "section_types/grid"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".section_body":
      observe: "content"
      updateMethod: "html"


class CMS.Views.HeroSection extends CMS.Views.ItemView
  template: "section_types/hero"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_title":
      classes:
        showing: "show_title"
    ".section_body":
      observe: "content"
      updateMethod: "html"
  
  onRender: =>
    # set default model content so that the image-picker can get at it
    super


class CMS.Views.CarouselSection extends CMS.Views.ItemView
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
      observe: "content"
      updateMethod: "html"
    ".captions":
      observe: "aside"
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

