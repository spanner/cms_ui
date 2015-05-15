class CMS.Views.SectionRenderer extends CMS.Views.ItemView
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
    #todo: remove empty elements?

  id: -> 
    "section_#{@model.get('id')}"
  
  wrapperClass: (section_type) =>
    section_type ?= 'default'
    "wrapper #{section_type}"


class CMS.Views.MainRenderer extends Backbone.Marionette.CompositeView
  template: "renderers/main"
  childView: CMS.Views.SectionRenderer
  childViewContainer: "#sections"
  tagName: "main"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"
    "#standfirst":
      observe: "introduction"
      updateMethod: "html"

  onRender: () =>
    @stickit()
    #todo: remove empty elements?


class CMS.Views.HeadRenderer extends Backbone.Marionette.ItemView
  template: "renderers/head"
  tagName: "head"

  bindings:
    "title":
      observe: "title"
      onGet: "headTitle"

  onRender: () =>
    # TODO: site-meta renderer drops in here
    @stickit()

  headTitle: (title) =>
    "site name | #{title}"
