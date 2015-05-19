class CMS.Views.SiteConfig extends Backbone.Marionette.ItemView
  template: "sites/config"

  bindings:
    ".title": "title"
    ".domain": "domain"
    "select.template":
      observe: "template"
      selectOptions:
        collection:
          'responsive': "Standard responsive"

  onRender: =>
    @stickit()
