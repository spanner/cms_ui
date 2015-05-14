class CMS.Views.CSS extends Backbone.Marionette.ItemView
  @mixin 'text'
  template: "sites/css"

  events:
    "click a.preview:not(.unavailable)": "previewCSS"
    "click a.revert:not(.unavailable)": "revertCSS"
    "paste .temp_css": "paste"

  ui:
    textarea: "textarea"

  bindings:
    "#sass":""
    "#temp_css": "pre_processed_style"
    "select.template":
      observe: "template"
      selectOptions:
        collection:
          default: "Default"
          spanner: "Spanner"
    # "a.save":
    #   attributes: [
    #     observe: ["temp_css","preview_css", "css"]
    #     visible: (vals) -> vals[0] is vals[1] and vals[0] isnt vals[2]
    # "a.preview":
    #   attributes: [
    #     observe: ["temp_css", "preview_css"]
    #     onGet: (vals) -> "unavailable" if vals[0] is vals[1]
    #     name: "class"
    #   ]
    "a.revert":
      attributes: [
        observe: ["css", "temp_css"]
        onGet: (vals) -> "unavailable" if vals[0] is vals[1]
        name: "class"
      ]

  onRender: =>
    @stickit()
    @editor = CodeMirror.fromTextArea @ui.textarea[0],
      mode: "sass"
      theme: "spanner"
      showCursorWhenSelecting: true
      lineNumbers: true
      tabSize: 2
    @editor.on "change", =>
      @ui.textarea.val @editor.getValue()
      @ui.textarea.trigger "change"

  previewCSS: =>
    type ||= "sass"
    $.ajax("#{_cms.apiUrl()}compile_css",
      type: "PUT"
      data:
        type: type
        pre_processed: @model.get("pre_processed_style")
    ).done (data) =>
      @model.set preview_css: data?.css
      # @model.previewCSS()

  revertCSS: =>
    @model.revertCSS()
    @editor.setValue @ui.textarea.val()

  save: =>
    @model.save(css:@model.get("preview_css"))
