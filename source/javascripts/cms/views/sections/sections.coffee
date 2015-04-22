class CMS.Views.SectionCrumb extends Backbone.Marionette.ItemView
  @mixin "crumbed"
  template: "sections/crumb"
  
  bindings:
    "[data-cms='name']": "name"

class CMS.Views.ListedSection extends Backbone.Marionette.ItemView
  template: "sections/listed"

  bindings:
    "[data-cms='name']":
      observe: "name"
      attributes: [
        observe: "uid"
        name: "href"
        onGet: "url"
      ]

  onRender: =>
    @stickit()

class CMS.Views.SectionsList extends Backbone.Marionette.CollectionView
  childView: CMS.Views.ListedSection
