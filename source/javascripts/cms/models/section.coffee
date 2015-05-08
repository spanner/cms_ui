class CMS.Models.Section extends CMS.Model
  @types: ['standard', 'gallery', 'hero', 'bigquote']
  savedAttributes: ["page_id", "content", "title", "aside", "section_type", "position"]

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
