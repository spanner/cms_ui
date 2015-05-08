class CMS.Views.SectionAdminMenu extends Backbone.Marionette.ItemView
  template: "editor/section_admin_menu"


class CMS.Views.Section extends Backbone.Marionette.ItemView
  template: "editor/section"
  tagName: "section"

  events:
    "click": "select"

  bindings:
    ":el":
      classes:
        selected: "selected"
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
    @stickit()
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
