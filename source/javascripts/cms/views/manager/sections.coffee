class CMS.Views.ListedSection extends  CMS.Views.ItemView
  template: "sections/listed"
  bindings:
    "a.title":
      observe: "id"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "sectionUrl"
      ]

  sectionUrl: (id) =>
    #TODO should this be an internal #link?
    "/sites/#{@model.getSite().get("slug")}/pages/#{@model.getPage().get("id")}/sections/#{id}"


class CMS.Views.SectionsList extends CMS.Views.CollectionView
  childView: CMS.Views.ListedSection


class CMS.Views.SectionsLayout extends CMS.Views.MenuLayout
  template: "manager/pages"

  bindings:
    'a.title': "title"
    "a.add":
      attributes: [
        name: "href"
        observe: "id"
        onGet: "newSectionUrl"
      ]

  onRender: =>
    @model.whenReady () =>
      @stickit()
      @_sections_list = new CMS.Views.SectionsList
        el: @$el.find(".menu")
      @_pages_tree.render()
      @_sections_lis = new CMS.Views.SectionsLayout
        el: @$el.find("#sections")
        collection: @model.sections
      @_sections_layout.render()

  show: (section) =>
    @log "⇒ show", section
    @model = section
    @model.whenReady =>
      @render()

  newSectionUrl: (page_id) =>
    "/sites/#{@model.getSite().get "slug"}/pages/#{page_id}/sections/new"
