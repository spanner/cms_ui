class CMS.Views.PageCrumb extends Backbone.Marionette.ItemView
  @mixin "crumbed"
  template: "pages/crumb"

  bindings:
    "[data-cms='name']": "name"
