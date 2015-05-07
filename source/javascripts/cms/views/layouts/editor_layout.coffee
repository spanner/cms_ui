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

  select: =>
    @model.select()

class CMS.Views.Page extends Backbone.Marionette.CompositeView
  template: "pages/page"
  childView: CMS.Views.PageSection
  childViewContainer: "main"

  bindings:
    "h1": "title"

  onRender: =>
    @stickit()

  show: (page) =>
    @model = page
    @model.whenReady =>
      @collection = @model.sections
      @render()

class CMS.Views.EditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/editor"

  onRender: =>
    @_page_view = new CMS.Views.Page
      el: @$el

  show: (site_slug, page_path="") =>
    @model.whenReady =>
      if site_slug and site = @model.sites.findWhere(slug: site_slug)
        site.whenReady =>
          if page = site.pages.findWhere(path: "/#{page_path}")
            @_page_view.show(page)
