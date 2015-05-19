class CMS.Views.ListedSection extends  CMS.Views.ItemView
  template: "sections/listed"
  tagName: "li"
  className: "item"

  events:
    "click a.title": "select"
    "click a.delete_section": "deleteSection"
    "click a.add_section": "addSection"

  bindings:
    ":el":
      classes:
        selected: "selected"
        destroyed: "deleted_at"
    "a.title":
      observe: "title"
      onGet: "sectionName"
      updateMethod: "html"
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

  addSection: =>
    pos = (@model.get('position') ? 0)
    above = @model.collection.filter (s) -> s.get('position') > pos
    _.each above, (s, i) ->
      console.log "displace", i, s
      s.set('position', s.get('position') + 1)
    @model.collection.add
      title: "New section"
      page_id: @model.get('page_id')
      position: pos + 1

  select: (e) =>
    e?.preventDefault()
    @model.select()

  sectionUrl: (id) =>
    "#section_#{id}"

  sectionName: (title) =>
    label = title || "New section"
    if label.length > 38
      label = label.substr(0, 36) + "..."
    label


class CMS.Views.SectionsList extends CMS.Views.MenuView
  template: "sections/menu"
  childView: CMS.Views.ListedSection
  
  initialize: ->
    super
    $.sections = @collection

  addItem: =>
    top_pos = @collection.last()?.get('position') ? 0
    console.log "addSection at pos", top_pos + 1
    @collection.add
      title: "New section"
      page_id: @collection.page.id
      position: top_pos + 1
    @collection.sort()


class CMS.Views.SectionsManagerLayout extends CMS.Views.MenuLayout
  template: "manager/sections"
  menuView: CMS.Views.SectionsList
