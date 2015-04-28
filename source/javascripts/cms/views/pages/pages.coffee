class CMS.Views.PageCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "pages/crumb"

  events:
    "click": "onClick"

  bindings:
    "span": "title"

  onClick: =>
    _cms.vent.trigger "toggle_list", "_pages_tree"

class CMS.Views.PageSection extends Backbone.Marionette.ItemView
  template: "sections/section"
  tagName: "section"

  onRender: =>
    @stickit()

class CMS.Views.Page extends Backbone.Marionette.CompositeView
  template: "pages/page"
  childView: CMS.Views.PageSection
  childViewContainer: "main"

  initialize: ->
    @collection = @model?.sections

  setModel: (model) =>
    @model = model
    @collection = @model?.sections
    if @model
      @stickit()
    else
      @unstickit()

class CMS.Views.PageBranch extends Backbone.Marionette.ItemView
  template: "pages/branch"

  events:
    "click": "onClick"

  bindings:
    ".cms-title":
      observe: "title"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "url"
      ]

  onRender: =>
    @stickit()

  url: (id) =>
    "/sites/#{@model.getSite().get "slug"}/pages/#{id}"

  onClick: =>
    _cms.vent.trigger "hide_list", "_pages_tree"

class CMS.Views.PagesTree extends Backbone.Marionette.CollectionView
  @mixin "collection", "toggle"
  # template: "pages/tree"
  childView: CMS.Views.PageBranch
