class CMS.Models.Section extends CMS.Model
  @types: ['default', 'twocol', 'asided', 'grid', 'hero', 'bigquote', 'bigtext', 'carousel']

  savedAttributes: ["id", "page_id", "title", "main_html", "secondary_html", "caption_html", "built_html", "section_type", "position", "deleted_at"]

  build: =>
    @on "change:selected", =>
      @collection?.trigger "model:change:selected"

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
