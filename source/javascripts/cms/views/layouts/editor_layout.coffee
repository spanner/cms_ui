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

  onRender: =>
    @stickit()
    @$el.append("<h2>##{@id()}</h2>")

  select: =>
    @model.select()


class CMS.Views.Page extends Backbone.Marionette.CompositeView
  template: "pages/page"
  childView: CMS.Views.PageSection
  childViewContainer: "main"

  bindings:
    "h1": "title"

  onRender: () =>
    @stickit()

class CMS.Views.EditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/editor"

  onRender: =>
    @model.whenReady =>
      @_page_view = new CMS.Views.Page
        model: @model
        collection: @model.sections
        el: @$el.find("#page")
      @_page_view.render()