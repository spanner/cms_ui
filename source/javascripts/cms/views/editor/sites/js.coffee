class CMS.Views.SiteJS extends Backbone.Marionette.ItemView
  template: "sites/js"

  ui:
    textarea: "textarea#js"
    header_area: "textarea#header"

  onRender: =>
    @stickit()
    _.delay @show, 2

  show: =>
    unless @editor
      @editor = CodeMirror.fromTextArea @ui.textarea[0],
        mode: @model.get("js_preprocessor") ? "javascript"
        theme: "spanner"
        showCursorWhenSelecting: true
        lineNumbers: true
        tabSize: 2
        extraKeys:
          "Cmd-Enter": @previewJS

      @model.on "change:js_preprocessor", (model, value) ->
        @editor.setOption mode: value

      @editor.on "change", =>
        @ui.textarea.val @editor.getValue()
        @ui.textarea.trigger "change"
