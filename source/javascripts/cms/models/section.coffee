class CMS.Models.Section extends CMS.Model
  savedAttributes: ["id", "page_id", "title", "main_html", "secondary_html", "caption_html", "built_html", "section_type", "position", "image_id", "video_id", "deleted_at"]

  build: =>
    @belongsTo 'image', 'image_id', @getSite().images
    @belongsTo 'video', 'video_id', @getSite().videos
    @on "change:selected", =>
      @collection?.trigger "model:change:selected"

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
