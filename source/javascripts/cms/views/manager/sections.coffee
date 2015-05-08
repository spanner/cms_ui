class CMS.Views.ListedSection extends  CMS.Views.ItemView
  template: "sections/listed"

  bindings:
    ":el":
      classes:
        selected: "selected"
    "a.title":
      observe: "id"
      onGet: "sectionName"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "sectionUrl"
      ]

  sectionUrl: (id) =>
    "#section_#{id}"
    
  sectionName: (id) =>
    if id
      "Section #{id}"
    else
      "New section"

  events:
    "click a.title": "select"
    "click a.delete_section": "deleteSection"

  deleteSection: =>
    console.log "destroy", @model
    @model?.destroy()

  select: (e) =>
    e.preventDefault() if e
    console.log "select section", @model
    @model.select()

  # onRender: =>
  #   @stickit()


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
    section.save().done =>
      _cms.navigate("#section_#{section.get('id')}")
