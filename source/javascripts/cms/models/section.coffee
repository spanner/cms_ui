class CMS.Models.Section extends CMS.Model
  @types: ['default', 'twocol', 'hero', 'bigquote', 'bigtext', 'carousel']

  savedAttributes: ["id", "page_id", "content", "title", "aside", "note", "section_type", "position", "deleted_at"]

  build: =>
    @on "change:selected", =>
      @collection?.trigger "model:change:selected"

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
