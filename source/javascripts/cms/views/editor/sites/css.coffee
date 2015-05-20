class CMS.Views.SiteCSS extends CMS.Views.ItemView
  @mixin 'text'
  template: "sites/css"

  events:
    "click a.preview": "previewCSS"
    "click a.revert": "revertCSS"
    "paste .temp_css": "paste"

  ui:
    textarea: "textarea#css"
    header_area: "textarea#header"

  bindings:
    ".font_css_url": "font_css_url"
    "#css": "css"
    "a.revert":
      observe: ["original_css", "css"]
      visible: "notTheSame"
      visibleFn: "visibleAsInlineBlock"
    "a.preview":
      observe: ["original_css", "css"]
      visible: "notTheSame"
      visibleFn: "visibleAsInlineBlock"

  onRender: =>
    @stickit()
    _.delay @show, 2

  show: =>
    unless @editor
      @editor = CodeMirror.fromTextArea @ui.textarea[0],
        mode: @model.get("css_preprocessor") ? 'sass'
        theme: "spanner"
        showCursorWhenSelecting: true
        lineNumbers: true
        tabSize: 2
        extraKeys:
          "Cmd-Enter": @previewCSS
      
      $.editor = @editor
      
      @model.on "change:css_preprocessor", (model, value) ->
        @editor.setOption mode: value

      @editor.on "change", =>
        @ui.textarea.val @editor.getValue()
        @ui.textarea.trigger "input"

  previewCSS: =>
    @model.previewCSS()

  revertCSS: =>
    @model.revertCSS()
    @editor?.setValue @ui.textarea.val()
