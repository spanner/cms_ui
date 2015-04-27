class CMS.Views.PageCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "pages/crumb"

  bindings:
    "span": "title"

  events:
    "click": 'onClick'

  onClick: =>
    console.log "click"

class CMS.Views.Page extends Backbone.Marionette.CompositeView
  template: "pages/page"
  childView: CMS.Views.Section
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
  bindings:
    "[data-cms='title']":
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

class CMS.Views.PagesTree extends Backbone.Marionette.CollectionView
  @mixin "collection"
  # template: "pages/tree"
  childView: CMS.Views.PageBranch
