class CMS.Models.Section extends CMS.Model
  savedAttributes: ["page_id"]

  build: =>
    @on "change:selected", =>
      @collection?.trigger "model:change:selected"

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()

  select: =>
    unless @get("selected")
      @collection.findWhere(selected:true)?.set selected:false
      @set selected: true
