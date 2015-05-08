class CMS.Views.SiteStyles extends Backbone.Marionette.ItemView
  template: "sites/styles"

  bindings:
    "style#custom": "preview_css"
    "link#template":
      attributes: [
        name: "href"        
        observe: "template"
        onGet: (name) -> "/stylesheets/templates/#{name}.css" if name
      ]

  onRender: =>
    @stickit()
