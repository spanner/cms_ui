class CMS.Views.EditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/editor"

  onRender: =>
    @_toolbar?.destroy()
    @model.whenReady =>
      # TODO: site-meta view drops in here?

      @_header_view = new CMS.Views.Header
        model: @model.getSite()
        el: @$el.find("header")
      @_header_view.render()

      @_page_view = new CMS.Views.Page
        model: @model
        collection: @model.sections
        el: @$el.find("#page")
      @_page_view.render()

      @_footer_view = new CMS.Views.Footer
        model: @model.getSite()
        el: @$el.find("footer")
      @_footer_view.render()

      @_toolbar = new MediumEditor '.editable',
        elementsContainer: $("#rte").get(0)
        fixedToolbar: true
        updateOnEmptySelection: true

