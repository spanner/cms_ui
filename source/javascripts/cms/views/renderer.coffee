class CMS.Views.SectionRenderer extends CMS.Views.ItemView
  template: "renderers/section"
  tagName: "section"

  onRender: () =>
    @$el.addClass(@model.get('section_type') or 'default')
    section_type = @model.get('section_type') or 'default'
    wrapper_class_name = 'Rendered' + section_type.charAt(0).toUpperCase() + section_type.substr(1).toLowerCase() + 'Section'
    wrapper_class = CMS.Views[wrapper_class_name] ? CMS.Views['RenderedDefaultSection']
    @_section_wrapper = new wrapper_class
      model: @model
      el: @$el
    @_section_wrapper.render()

  id: -> 
    "section_#{@model.get('id')}"


class CMS.Views.PageRenderer extends Backbone.Marionette.CompositeView
  childView: CMS.Views.SectionRenderer
  childViewContainer: "#sections"
  tagName: "body"

  bindings:
    "h1.pagetitle":
      observe: "title"
      updateMethod: "html"
    "#standfirst":
      observe: "introduction"
      updateMethod: "html"

  template: (data) =>
    @model.get('page_type')?.get('html') or "<header /><main /><footer />"



class CMS.Views.SiteNavigationRenderer extends CMS.Views.ItemView
  template: false
  tagName: "nav"

  onRender: =>
    for p in @model.pages.where(nav: true)
      a = $("<a href=\"#{p.path}\">#{p.nav_name or p.title}</a>")
      a.attr('href', p.get('path'))
      a.text(p.get('nav_name') or p.get('title'))
      @$el.append(a)
  
  rendered: =>
    @render()
    @$el.get(0).outerHTML


class CMS.Views.RenderedSectionView extends CMS.Views.ItemView
  tagName: "section"

  onRender: =>
    @stickit()

  typeClass: (section_type) =>
    section_type or 'default'


class CMS.Views.RenderedDefaultSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/default"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
    ".section_aside":
      observe: "secondary_html"
      updateMethod: "html"
    ".section_note":
      observe: "caption_html"
      updateMethod: "html"


class CMS.Views.RenderedTwocolSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/twocol"

  bindings:
    "h2":
      observe: "title"
    ".col.first":
      observe: "main_html"
      updateMethod: "html"
    ".col.second":
      observe: "secondary_html"
      updateMethod: "html"


class CMS.Views.RenderedAsidequoteSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/asidequote"

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


class CMS.Views.RenderedAsideimageSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/asideimage"

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


class CMS.Views.RenderedBigquoteSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/bigquote"

  bindings:
    ".quoted":
      observe: "main_html"
      updateMethod: "text"
    ".speaker":
      observe: "caption_html"
      updateMethod: "text"


class CMS.Views.RenderedBigtextSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/bigtext"

  bindings:
    ".section_body":
      observe: "main_html"
      updateMethod: "html"


class CMS.Views.RenderedGridSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/grid"

  bindings:
    ".built":
      observe: "built_html"
      updateMethod: "html"


class CMS.Views.RenderedHeroSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/hero"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"
    ".built":
      observe: "built_html"
      updateMethod: "html"


class CMS.Views.RenderedCarouselSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/carousel"

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
