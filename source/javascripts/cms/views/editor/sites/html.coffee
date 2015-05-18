class CMS.Views.SiteHtml extends Backbone.Marionette.ItemView
  @mixin 'text'
  template: "sites/html"

  bindings:
    "#header": "header"
    "#footer": "footer"

  ui:
    header_area: "textarea#header"
    footer_area: "textarea#footer"

  onRender: =>
    @stickit()
    _.delay @show, 2

  show: =>
    console.log "SiteHtml.show"
    unless @header_editor
      @header_editor = CodeMirror.fromTextArea @ui.header_area[0],
        mode: "markdown"
        theme: "spanner"
        lineNumbers: true
        showCursorWhenSelecting: true
        tabSize: 2
      @header_editor.on "change", =>
        @ui.header_area.val @header_editor.getValue()
        @ui.header_area.trigger "change"
    unless @footer_editor
      @footer_editor = CodeMirror.fromTextArea @ui.footer_area[0],
        mode: "markdown"
        theme: "spanner"
        lineNumbers: true
        showCursorWhenSelecting: true
        tabSize: 2
      @footer_editor.on "change", =>
        @ui.footer_area.val @footer_editor.getValue()
        @ui.footer_area.trigger "change"
