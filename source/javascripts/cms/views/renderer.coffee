class CMS.Views.SectionRenderer extends CMS.Views.ItemView
  template: "renderers/section"
  tagName: "section"

  onRender: () =>
    section_type = @model.get('section_type') or 'default'
    wrapper_class_name = 'Rendered' + section_type.charAt(0).toUpperCase() + section_type.substr(1).toLowerCase() + 'Section'
    wrapper_class = CMS.Views[wrapper_class_name] ? CMS.Views['RenderedDefaultSection']
    @_section_wrapper = new wrapper_class
      model: @model
      el: @$el
    @_section_wrapper.render()

  id: -> 
    "section_#{@model.get('id')}"
  
  wrapperClass: (section_type) =>
    section_type ?= 'default'
    "wrapper #{section_type}"


class CMS.Views.PageRenderer extends Backbone.Marionette.CompositeView
  childView: CMS.Views.SectionRenderer
  childViewContainer: "main"
  tagName: "body"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"
    "#standfirst":
      observe: "introduction"
      updateMethod: "html"

  template: (data) =>
    @model.page_type?.get('template') or "<header /><main /><footer />"

  onRender: () =>
    @stickit()


class CMS.Views.PageLinkRenderer extends CMS.Views.ItemView
  template: false
  tagName: "a"
  className: "nav"
  bindings: 
    ':el':
      observe: ["nav_name", "title"]
      onGet: "thisOrThat"
      attributes: [
        name: 'href'
        observe: 'path'
      ]


class CMS.Views.SiteNavigationRenderer extends CMS.Views.CollectionView
  tagName: "nav"
  childView: CMS.Views.PageLinkRenderer


class CMS.Views.RenderedSectionView extends CMS.Views.ItemView
  tagName: "section"
  onRender: =>
    @stickit()


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


class CMS.Views.TwocolSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/twocol"

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


class CMS.Views.AsidedSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/asided"

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


class CMS.Views.RenderedBigquoteSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/bigquote"

  bindings:
    ".quoted":
      observe: "main_html"
      updateMethod: "text"
    ".speaker":
      observe: "secondary_html"
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
