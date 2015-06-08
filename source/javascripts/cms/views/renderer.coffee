class CMS.Views.PageSectionRenderer extends CMS.Views.ItemView
  template: "renderers/section"
  tagName: "section"

  bindings:
    ".wrapper":
      attributes: [
        name: "class"
        observe: "section_type"
        onGet: "wrapperClass"
      ]
    "h2.section":
      observe: "title"
      updateMethod: "html"
    ".section_body":
      observe: "content"
      updateMethod: "html"
    ".section_aside":
      observe: "aside"
      updateMethod: "html"

  onRender: () =>
    @stickit()

  id: -> 
    "section_#{@model.get('id')}"
  
  wrapperClass: (section_type) =>
    section_type ?= 'default'
    "wrapper #{section_type}"


class CMS.Views.PageRenderer extends Backbone.Marionette.CompositeView
  childView: CMS.Views.PageSectionRenderer
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

