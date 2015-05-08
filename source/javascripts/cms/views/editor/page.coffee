class CMS.Views.PageSection extends Backbone.Marionette.ItemView
  template: "sections/section"
  tagName: "section"
  id: -> "section_#{@model.id}"

  events:
    "click": "select"

  bindings:
    ":el":
      classes:
        selected: "selected"
    "h2.label":
      observe: "id"
      onGet: "sectionName"

  onRender: =>
    @stickit()

  select: =>
    @model.select()
  
  sectionName: (id) =>
    if id
      "Section #{id}"
    else
      "New section"


class CMS.Views.Page extends Backbone.Marionette.CompositeView
  template: "pages/page"
  childView: CMS.Views.PageSection
  childViewContainer: "main"

  bindings:
    "h1": "title"

  onRender: () =>
    @_site_styles = new CMS.Views.SiteStyles
      model: @model.getSite()
      el: @$el.find("#styles")
    @_site_styles.render()
    @stickit()
