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

class CMS.Views.SectionsList extends CMS.Views.CollectionView
  childView: CMS.Views.ListedSection


class CMS.Views.SectionsLayout extends CMS.Views.MenuLayout
  template: "manager/sections"

  events:
    "click a.add_section": "addSection"
    "click a.delete_section": "deleteSection"

  bindings:
    'a.title': "pos"

  initialize: ->
    @collection.on "model:change:selected destroy add", @show

  onRender: =>
    if @model
      @model.whenReady () =>
        @$el.find("a.delete_section").show()
        @stickit()
    else
      @$el.find("a.delete_section").hide()

  show: =>
    if @model = @collection.findWhere(selected: true)
      @log "⇒ show", @model
      @model.load() unless @model.isReady()
      @render()

  deleteSection: =>
    console.log "destroy", @model
    @model?.destroy()

  addSection: =>
    console.log "add section to page:", @collection.page.get("path")
    @collection.add(page_id:@collection.page.id).select()
