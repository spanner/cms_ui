class CMS.Views.SiteMeta extends Backbone.Marionette.ItemView
  template: "sites/meta"

  modelEvents:
    "run_script": "runScript"

  bindings:
    "style#custom": "preview_css"
    "script#custom": "js"
    "link#template":
      attributes: [
        name: "href"        
        observe: "template"
        onGet: (name) -> "/stylesheets/templates/#{name}.css" if name
      ]

  onRender: =>
    @stickit()

  runScript: =>
    console.log @$el.find("script")
