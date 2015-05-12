class CMS.Views.SectionAdminMenu extends CMS.Views.ItemView
  template: "editor/section_admin_menu"
  
  onRender: () =>
    menu = @$el.find('.section_menu')
    for type in CMS.Models.Section.types
      do (type) =>
        cssclass = "section_type #{type}"
        cssclass += " selected" if type is @model.get('section_type')
        cssclass += " selected" if type is "default" and not @model.get('section_type')
        a = $("<a class=\"#{cssclass}\"></a>")
        a.appendTo(menu)
        a.click (e) =>
          e?.preventDefault()
          @setType(type)
  
  setType: (type) =>
    console.log "setType", type
    @model.set 'section_type', type
    @render()


class CMS.Views.Section extends CMS.Views.ItemView
  template: "editor/section"
  tagName: "section"

  events:
    "click": "select"

  bindings:
    ":el":
      observe: "deleted_at"
      visible: "untrue"
      classes:
        selected: "selected"
        destroyed: "destroyed"
    "h2.section":
      observe: "title"
      updateMethod: "html"
    ".section_body":
      observe: "content"
      updateMethod: "html"
    ".section_aside":
      observe: "aside"
      updateMethod: "html"

  id: -> 
    "section_#{@model.get('id')}"

  onRender: =>
    super
    @_admin_menu = new CMS.Views.SectionAdminMenu
      model: @model
      el: @$el.find('.admin')
    @_admin_menu.render()

  select: =>
    @model.select()
  
  sectionName: (id) =>
    if id
      "Section #{id}"
    else
      "New section"
