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

  bindings:
    "h1.pagetitle":
      observe: "title"
    "date":
      observe: "published_at"
      onGet: "dayMonthYear"
    "#standfirst":
      observe: "introduction"
      updateMethod: "html"
      
  onRender: () =>
    @stickit()

  template: (data) =>
    @model.get('page_type')?.get('html') or "<header /><main /><footer />"

  dayMonthYear: (date) =>
    if date
      console.log "date is", date
      months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
      [date.getDate(), months[date.getMonth()], date.getFullYear()].join(' ')
    else
      ""


class CMS.Views.SiteNavigationRenderer extends CMS.Views.ItemView
  template: false
  tagName: "nav"

  onRender: =>
    for p in @model.pages.where(nav: true)
      if p.published()
        a = $("<a href=\"#{p.path}\">#{p.nav_name or p.title}</a>")
        a.attr('href', p.get('path'))
        a.text(p.get('nav_name') or p.get('title'))
        @$el.append(a)
  
  rendered: =>
    @render()
    @$el.get(0).outerHTML


class CMS.Views.RenderedSectionView extends CMS.Views.ItemView
  tagName: "section"

  ui:
    built: ".built"
    picture: ".picture"
    content: ".content"
    body: ".section_body"

  onRender: =>
    @stickit()

  typeClass: (section_type) =>
    section_type or 'default'

  imageOrVideo: (size) =>
    @ui.picture.empty()
    image_or_video = new CMS.Views.ImageOrVideo
      model: @model
      el: @ui.picture
      size: size
    image_or_video.render()


class CMS.Views.RenderedDefaultSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/default"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
      onSet: "cleanHtml"

  assetInserter: =>
    @_inserter = new CMS.Views.AssetInserter
      model: @model
    @_inserter.render()
    @_inserter.attachTo(@ui.body)


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
    "aside .caption":
      observe: "caption_html"
      updateMethod: "html"

  onRender: =>
    super
    @imageOrVideo('half')


class CMS.Views.RenderedBigquoteSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/bigquote"

  bindings:
    ".quoted":
      observe: "main_html"
      updateMethod: "text"
    ".speaker":
      observe: "caption_html"
      updateMethod: "text"


class CMS.Views.RenderedOnecolSection extends CMS.Views.RenderedSectionView
  template: "renderers/section_types/onecol"

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

  onRender: =>
    super
    @imageOrVideo('hero')



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
