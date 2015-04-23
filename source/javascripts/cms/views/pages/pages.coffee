class CMS.Views.PageCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "pages/crumb"

  bindings:
    "[data-cms='name']": "name"

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
