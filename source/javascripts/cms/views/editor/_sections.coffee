class CMS.Views.SectionAdminMenu extends CMS.Views.ItemView
  template: "editor/section_admin_menu"
  
  events:
    "click a.menu": "toggleMenu"
    "click div.properties": "containEvent"
  
  modelEvents:
    "change:section_type": "setSelection"
  
  bindings:
    "input.show_title": "show_title"
  
  onRender: () =>
    @stickit()
    @_menu = @$el.find('.menu')
    @_typer = @$el.find('.section_types')
    for type in CMS.Models.Section.types
      do (type) =>
        a = $("<a class=\"section_type #{type}\"></a>").appendTo(@_typer)
        a.click (e) =>
          e?.preventDefault()
          @setType(type)
      @setSelection()

  setSelection: () =>
    type = @model.get('section_type') or 'default'
    @_typer.find("a.section_type").removeClass('selected')
    @_typer.find("a.#{type}").addClass('selected')

  toggleMenu: (e) =>
    e?.preventDefault()
    e?.stopPropagation()
    if @_menu.hasClass('open')
      @closeMenu()
    else
      @openMenu()

  openMenu: () =>
    $('.menu').not(@_menu).removeClass('open')
    @_menu.addClass('open')
    $(document).bind "click", @closeMenu
    
  closeMenu: () =>
    $(document).unbind "click", @closeMenu
    @_menu.removeClass('open')

  setType: (type) =>
    @model.set 'section_type', type,
      stickitChange: true

class CMS.Views.Section extends CMS.Views.ItemView
  template: "editor/section"
  tagName: "section"

  events:
    "click": "select"

  bindings:
    ":el":
      observe: "deleted_at"
      visible: "untrue"
      classes:
        selected: "selected"
        destroyed: "destroyed"
    ".wrapper":
      attributes: [
        name: "class"
        observe: "section_type"
        onGet: "wrapperClass"
      ]

  id: -> 
    "section_#{@model.get('id')}"

  initialize: =>
    super
    @model.on "change:section_type", @renderSectionType

  onRender: =>
    super
    @_admin_menu = new CMS.Views.SectionAdminMenu
      model: @model
      el: @$el.find('.admin')
    @_admin_menu.render()
    @renderSectionType()
  
  renderSectionType: () =>
    section_type = @model.get('section_type') or 'default'
    wrapper_class_name = section_type.charAt(0).toUpperCase() + section_type.substr(1).toLowerCase() + 'Section'
    wrapper_class = CMS.Views[wrapper_class_name] ? CMS.Views['DefaultSection']
    @_section_wrapper = new wrapper_class
      model: @model
      el: @$el.find('.wrapper')
    @_section_wrapper.render()

  select: =>
    @model.select()

  wrapperClass: (section_type) =>
    section_type ?= 'default'
    "wrapper #{section_type}"


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

