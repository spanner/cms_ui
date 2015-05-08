class CMS.Views.ListedSection extends  CMS.Views.ItemView
  template: "sections/listed"

  events:
    "click a.title": "select"
    "click a.delete_section": "deleteSection"

  bindings:
    ":el":
      classes:
        selected: "selected"
        destroyed: "deleted_at"
    "a.title":
      observe: "id"
      onGet: "sectionName"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "sectionUrl"
      ]

  onRender: () =>
    @stickit()
    @model.select() if window.location.hash is @sectionUrl(@model.get('id'))

  deleteSection: =>
    @model?.destroyReversibly()

  select: (e) =>
    e.preventDefault() if e
    @model.select()

  sectionUrl: (id) =>
    "#section_#{id}"
    
  sectionName: (id) =>
    if id
      "Section #{id}"
    else
      "New section"


class CMS.Views.SectionsList extends CMS.Views.MenuView
  childView: CMS.Views.ListedSection


class CMS.Views.SectionsLayout extends CMS.Views.MenuLayout
  template: "manager/sections"

  events:
    "click a.add_section": "addSection"
    "click > .header a.title": "toggleMenu"

  bindings:
    'a.title': "pos"

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
    section = @collection.add
      page_id: @collection.page.id
