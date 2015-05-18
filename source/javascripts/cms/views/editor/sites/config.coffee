class CMS.Views.SiteConfig extends Backbone.Marionette.ItemView
  template: "sites/config"

  bindings:
    ".title": "title"
    ".domain": "domain"
    "select.template":
      observe: "template"
      selectOptions:
        collection:
          default: "Default"
          spanner: "Spanner"
          invictus: "Invictus"

  onRender: =>
    @stickit()
