# class CMS.Views.ListedSection extends  CMS.Views.ItemView
#   template: "sections/listed"
#
#   events:
#     "click a.title": "select"
#
#   sectionUrl: (id) =>
#     #TODO should this be an internal #link?
#     "/sites/#{@model.getSite().get("slug")}#{@model.getPage().get("path")}#section_#{id}"
#
#   select: =>
#     console.log "select section", @model

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
    "click a.delete_section": "deleteSection"
    "click > .header a.title": "toggleMenu"

  bindings:
    'a.title': "pos"

  initialize: ->
    @collection.on "model:change:selected destroy add", @show

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

  deleteSection: =>
    console.log "destroy", @model
    @model?.destroy()

  toggleMenu: =>
    if @_sections_list.$el.css('display') isnt 'none'
      @_sections_list.hide()
    else
      @_sections_list.show()

  addSection: =>
    console.log "add section to page:", @collection.page.get("path")
    @collection.add(page_id:@collection.page.id).select()
