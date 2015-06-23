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

  # Image data is held in file.
  # *url attributes are computed on the server when we save the asset.
  # so we can anticipate those here with data urls, at visibly lower quality.
  #
  resizeImage: (img, w=48) =>
    unless @get('url')
      if img.height > img.width
        h = w * (img.height / img.width)
      else
        h = w
        w = h * (img.width / img.height)
      canvas = document.createElement('canvas')
      canvas.width = w
      canvas.height = h
      ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0, w, h)
      preview = canvas.toDataURL('image/png')
      @set "url", preview
