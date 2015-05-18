class CMS.Views.SiteCSS extends Backbone.Marionette.ItemView
  @mixin 'text'
  template: "sites/css"

  events:
    "click a.preview:not(.unavailable)": "previewCSS"
    "click a.revert:not(.unavailable)": "revertCSS"
    "paste .temp_css": "paste"

  ui:
    textarea: "textarea#temp_css"
    header_area: "textarea#header"

  bindings:
    "#temp_css": "temp_css"
    "select.template":
      observe: "template"
      selectOptions:
        collection:
          default: "Default"
          spanner: "Spanner"

    "style": "preview_css"

    "a.revert":
      attributes: [
        observe: ["css", "temp_css"]
        onGet: (vals) -> "unavailable" if vals[0] is vals[1]
        name: "class"
      ]

  onRender: =>
    @stickit()
    console.log "CSS.show"
    unless @editor
      @editor = CodeMirror.fromTextArea @ui.textarea[0],
        mode: @model.get("css_preprocessor")
        theme: "spanner"
        showCursorWhenSelecting: true
        lineNumbers: true
        tabSize: 2
        extraKeys:
          "Cmd-Enter": @previewCSS

      @model.on "change:css_preprocessor", (model, value) ->
        @editor.setOption mode: value

      @editor.on "change", =>
        @ui.textarea.val @editor.getValue()
        @ui.textarea.trigger "change"

  previewCSS: =>
    @model.compileCSS()

  revertCSS: =>
    @model.revertCSS()
    @editor?.setValue @ui.textarea.val()

  save: =>
    @model.save(css:@model.get("preview_css"))
