class CMS.Views.EditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/editor"

  onRender: =>
    @model.whenReady =>
      @_page_view = new CMS.Views.Page
        model: @model
        collection: @model.sections
        el: @$el.find("#page")
      @_page_view.render()
      
      