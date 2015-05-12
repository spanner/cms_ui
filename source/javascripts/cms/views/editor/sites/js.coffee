class CMS.Views.JS extends Backbone.Marionette.ItemView
  @mixin 'text'
  template: "sites/js"

  events:
    "click a.run": "runJS"
    "paste .js": "paste"

  bindings:
    ".js": "js"

  onRender: =>
    @stickit()

  runJS: =>
    @model.trigger "run_script"
