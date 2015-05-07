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
    "#section_#{id}"


class CMS.Views.SectionsList extends CMS.Views.CollectionView
  childView: CMS.Views.ListedSection


class CMS.Views.SectionsLayout extends CMS.Views.MenuLayout
  template: "manager/sections"

  events:
    "click a.add_section": "addSection"
    "click > .header a.title": "toggleMenu"

  bindings:
    'a.title':
      observe: "id"
      onGet: "orNew"

  onRender: =>
    @_sections_list = new CMS.Views.SectionsList
      el: @$el.find(".menu")
      collection: @collection
    @_sections_list.render()
    @model?.whenReady () =>
      @stickit()

  show: (section) =>
    @log "⇒ show", section
    @model = section
    @model.load() unless @model.isReady()
    @render()

  toggleMenu: =>
    if @_sections_list.$el.css('display') isnt 'none'
      @_sections_list.hide()
    else
      @_sections_list.show()

  addSection: =>
    @collection.add(page_id: @collection.page.id)

  orNew: (id) =>
    id || "new"
    