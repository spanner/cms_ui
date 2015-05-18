class CMS.Views.SiteCSS extends CMS.Views.ItemView
  @mixin 'text'
  template: "sites/css"

  events:
    "click a.preview": "previewCSS"
    "click a.revert": "revertCSS"
    "paste .temp_css": "paste"

  ui:
    textarea: "textarea#temp_css"
    header_area: "textarea#header"

  bindings:
    "#temp_css": "temp_css"
    "style": "preview_css"

    "a.revert":
      observe: ["css", "temp_css"]
      visible: "notTheSame"
      visibleFn: "visibleAsInlineBlock"

    "a.preview":
      observe: ["preview_css", "temp_css"]
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
    @model.compileCSS()

  revertCSS: =>
    @model.revertCSS()
    @editor?.setValue @ui.textarea.val()

  save: =>
    @model.save(css: @model.get("preview_css"))
