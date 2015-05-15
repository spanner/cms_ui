class CMS.Views.SiteEditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/site_editor"

  events:
    "click nav a": "showTab"

  bindings:
    "span.title": "title"

  onRender: =>
    @stickit()
    $.site = @model
    @model.whenReady =>
      @_css_view = new CMS.Views.CSS
        el: @$el.find("#style")
        model: @model
      @_css_view.render()
      @_js_view = new CMS.Views.JS
        el: @$el.find("#script")
        model: @model
      @_js_view.render()
      @_config_view = new CMS.Views.SiteConfig
        el: @$el.find("#config")
        model: @model
      @_config_view.render()

  showTab: (e) =>
    el = $(e.currentTarget)
    tab = el.attr("class")
    unless el.hasClass("current")
      @$el.find(".current").removeClass("current")
      @$el.find(".#{tab},##{tab}").addClass("current")
