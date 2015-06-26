class CMS.Models.Section extends CMS.Model
  savedAttributes: ["id", "page_id", "title", "main_html", "secondary_html", "caption_html", "built_html", "section_type", "style", "subject_page_id", "position", "image_id", "video_id", "deleted_at"]

  build: =>
    @belongsTo 'image', 'image_id', @getSite().images
    @belongsTo 'video', 'video_id', @getSite().videos
    @belongsTo 'subject_page', 'subject_page_id', @getSite().pages
    @on "change:selected", =>
      @collection?.trigger "model:change:selected"

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
