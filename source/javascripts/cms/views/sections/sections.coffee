class CMS.Views.SectionCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "sections/crumb"

  events:
    "click": "onClick"

  bindings:
    "span": "id"

  onClick: =>
    _cms.vent.trigger "toggle_list", "_sections_list"

class CMS.Views.ListedSection extends Backbone.Marionette.ItemView
  template: "sections/listed"

  events:
    "click": "onClick"

  bindings:
    ".cms-title":
      observe: "id"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "url"
      ]

  onRender: =>
    @stickit()

  url: (id) =>
    "/sites/#{@model.getSite().get("slug")}/pages/#{@model.getPage().get("id")}/sections/#{id}"

  onClick: =>
    _cms.vent.trigger "hide_list", "_sections_list"

class CMS.Views.SectionsList extends Backbone.Marionette.CompositeView
  @mixin "collection", "toggle"
  template: "sections/list"
  childView: CMS.Views.ListedSection
  childViewContainer: ".cms-sections"

  bindings:
    ".cms-add":
      attributes: [
        name: "href"
        observe: "id"
        onGet: "newSectionUrl"
      ]

  setModel: (model) =>
    @model = model
    if @model
      @model.populate()
      @stickit()
      @collection = @model.sections
    else
      @unstickit()
    @render()

  newSectionUrl: (id) =>
    "/sites/#{@model.getSite().get "slug"}/pages/#{id}/sections/new"
    
