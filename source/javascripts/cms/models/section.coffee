class CMS.Models.Section extends CMS.Model
  savedAttributes: ["id", "page_id", "title", "main_html", "secondary_html", "caption_html", "built_html", "section_type", "position", "image_id", "video_id", "deleted_at"]

  build: =>
    @on "change:selected", =>
      @collection?.trigger "model:change:selected"

    if vid = @get('video_id')
      @set 'video', @getSite().videos.get(vid), silent: true
    @on "change:video", (section, video, options) =>
      if video
        if id = video.get('id')
          @set "video_id", id, stickitChange: true
        else
          video.once "change:id", (vm, new_id) =>
            @set "video_id", new_id, stickitChange: true
      else
        @set "video_id", null, stickitChange: true

    if iid = @get('image_id')
      @set 'image', @getSite().images.get(iid), silent: true
    @on "change:image", (section, image, options) =>
      if image
        if id = image.get('id')
          @set "image_id", id, stickitChange: true
        else
          image.once "change:id", (im, new_id) =>
            @set "image_id", new_id, stickitChange: true
      else
        @set "image_id", null, stickitChange: true

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
