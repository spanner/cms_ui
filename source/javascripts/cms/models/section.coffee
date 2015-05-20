class CMS.Models.Section extends CMS.Model
  @types: ['default', 'twocol', 'asided', 'grid', 'hero', 'bigquote', 'bigtext', 'carousel']

  savedAttributes: ["id", "page_id", "content", "title", "show_title", "aside", "note", "section_type", "position", "deleted_at"]

  build: =>
    @on "change:selected", =>
      @collection?.trigger "model:change:selected"

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
