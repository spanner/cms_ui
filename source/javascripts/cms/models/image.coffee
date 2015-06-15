class CMS.Models.Image extends CMS.Model
  savedAttributes: ["file", "file_name"]

  initialize: () ->
    @on 'change:file', @getThumb

  getThumb: (data) =>
    unless @get('thumb_url')
      img = document.createElement('img')
      w = 48
      img.onload = =>
        @resizeImage(img, 48)
      img.src = @get('file')

  resizeImage: (img, w=48) =>
    unless @get('thumb_url')
      h = w * (img.height / img.width)
      canvas = document.createElement('canvas')
      ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0, w, h);
      preview = canvas.toDataURL('image/png')
      @set "preview_url", preview
      @set "thumb_url", preview
