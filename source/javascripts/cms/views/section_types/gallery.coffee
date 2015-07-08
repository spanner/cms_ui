## Gallery of images
#
# This is an html-builder: it uses a helper collection view to assemble a list of image blocks.
# TODO: styler on the section to choose between carousel and grid, perhaps at different sizes.
# TODO: styler on the individual image to embiggen it.

class CMS.Views.GalleryImage extends CMS.Views.AssetView
  template: "images/galleried"
  tagName: "div"
  className: "block"

  ui:
    controls: ".cms-buttons"

  events: 
    "click a.add_image": "addImage"
    "click a.delete_image": "removeImage"

  bindings:
    ":el":
      attributes: [
        name: "data-image-id"
        observe: "id"
      ]
    "a.zoom":
      attributes: [
        name: "href"
        observe: "url"
      ]
    "figure.image":
      attributes: [
        name: "style"
        observe: "url"
        onGet: "backgroundAtSize"
      ]
    "figcaption":
      observe: "caption"

  onRender: =>
    super
    @_image_picker = new CMS.Views.ImagePickerLayout
      collection: @model.collection
    @_image_picker.render()
    @_image_picker.on 'selected', @setImage
    @ui.controls.append @_image_picker.el

  setImage: (image) =>
    console.log "gallery image setImage", image
    @model = image
    @stickit()
    @sectionChanged()

  removeImage: (e) =>
    e?.preventDefault()
    @collection.remove(@model)

  addImage: (e) =>
    e?.preventDefault()
    @collection.add 
      is_meant_to_be_empty: true
    ,
      at: @collection.indexOf(@model) + 1

  sectionChanged: () =>
    @$el.trigger('input')


class CMS.Views.NoGalleryImages extends Backbone.Marionette.ItemView
  template: "images/none"


class CMS.Views.GalleryImages extends CMS.Views.CollectionView
  className: "block_images"
  childView: CMS.Views.GalleryImage

  childViewOptions: =>
    collection: @collection



class CMS.Views.GallerySection extends CMS.Views.SectionView
  template: "section_types/gallery"

  bindings:
    ":el":
      attributes: [
        name: "class"
        observe: "style"
      ]
    "h2":
      observe: "title"
      updateMethod: "html"

  initialize: ->
    @_images = new CMS.Collections.Images
    super

  readBuiltHtml: =>
    @_images.reset()
    if html = @model.get('built_html')
      site = @model.getSite()
      $(html).find('div.block').each (i, block) =>
        if image_id = $(block).data('image-id')
          if image = site.images.get(image_id)
            @_images.add image
    @renderContent()

  renderContent: =>
    @ui.built.empty()
    unless @_images.length
      images = @model.getSite().images
      @_images.reset(images[0..15])
    @_image_blocks = new CMS.Views.GalleryImages collection: @_images
    @_image_blocks.render()
    @ui.built.append @_image_blocks.el
    # no need for load-waiting here: images are loaded with the site.
    @saveBuiltHtml()
    @$el.on 'input', @saveBuiltHtml



