class CMS.Views.DefaultSection extends CMS.Views.SectionView
  template: "section_types/default"
  tagName: "section"

  bindings:
    "h2.section":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
      onSet: "cleanHtml"

  onRender: =>
    super
    @assetInserter()
    @ui.body.find('figure.image').each (i, fig) =>
      if img_id = $(fig).data('image-id')
        caption = $(fig).find('figcaption').text()
        if image = @model.getSite().images.get(img_id)
          img = new CMS.Views.InlineImage(model: image, el: fig)
          img.render()
          img.setCaption(caption)
    @ui.body.find('figure.video').each (i, fig) =>
      if vid_id = $(fig).data('video-id')
        caption = $(fig).find('figcaption').text()
        if video = @model.getSite().videos.get(vid_id)
          vid = new CMS.Views.InlineVideo(model: video, el: fig)
          vid.render()
          vid.setCaption(caption)

  assetInserter: =>
    @_inserter = new CMS.Views.AssetInserter
      model: @model
    @_inserter.render()
    @_inserter.attachTo(@ui.body)
