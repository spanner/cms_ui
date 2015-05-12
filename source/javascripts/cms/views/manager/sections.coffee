class CMS.Views.ListedSection extends  CMS.Views.ItemView
  template: "sections/listed"
  tagName: "li"
  className: "item"

  events:
    "click a.title": "select"
    "click a.delete_section": "deleteSection"

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

  select: (e) =>
    e.preventDefault() if e
    @model.select()

  sectionUrl: (id) =>
    "#section_#{id}"
    
  sectionName: (title) =>
    label = title || "New section"
    if label.length > 38
      label = label.substr(0,36) + "..."
    label


class CMS.Views.SectionsList extends CMS.Views.MenuView
  template: "sections/menu"
  childView: CMS.Views.ListedSection


class CMS.Views.SectionsLayout extends CMS.Views.MenuLayout
  template: "manager/sections"
  menuView: CMS.Views.SectionsList

  events:
    "click a.add_section": "addSection"
    "click > .header a.title": "toggleMenu"

  bindings:
    'a.title': "pos"

  onRender: =>
    super
    @model?.whenReady () =>
      @stickit()

  addSection: =>
    section = @collection.add
      page_id: @collection.page.id
