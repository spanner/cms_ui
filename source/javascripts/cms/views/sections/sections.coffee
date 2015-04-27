class CMS.Views.SectionCrumb extends Backbone.Marionette.ItemView
  @mixin "item"
  template: "sections/crumb"
  
  bindings:
    "span": "id"

class CMS.Views.ListedSection extends Backbone.Marionette.ItemView
  template: "sections/listed"

  bindings:
    ".cms-title":
      observe: "id"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "url"
      ]

  onRender: =>
    @stickit()

  url: (id) =>
    "/sites/#{@model.getSite().get("slug")}/pages/#{@model.getPage().get("id")}/sections/#{id}"

class CMS.Views.SectionsList extends Backbone.Marionette.CollectionView
  @mixin "collection"
  childView: CMS.Views.ListedSection
