## Gallery of images
#
# This is an html-builder: it uses a helper collection view to assemble a list of image blocks
# that can be displayed as list, grid or slideshow.


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
    if section = @options.section
      @options.section.on "change:style", @setSize
  
  setSize: (section, style) =>
    console.log "setSize", style
    @_size = switch style
      when "slides" then "full"
      when "list" then "thumb"
      else "half"
    @stickit()

  setImage: (image) =>
    @model = image
    @stickit()
    @sectionChanged()

  removeImage: (e) =>
    e?.preventDefault()
    @collection.remove(@model)
    @sectionChanged()

  addImage: (e) =>
    e?.preventDefault()
    @collection.add 
      is_meant_to_be_empty: true
    ,
      at: @collection.indexOf(@model) + 1
    @sectionChanged()

  sectionChanged: () =>
    @$el.trigger('input')


class CMS.Views.NoGalleryImages extends Backbone.Marionette.ItemView
  template: "images/none"


class CMS.Views.GalleryImages extends CMS.Views.CollectionView
  className: "images"
  childView: CMS.Views.GalleryImage

  childViewOptions: (model, index) =>
    section: @options.section
    child_index: index
    collection: @collection
    
  initialize: (options) ->
    @section = options['section']
    @section.on "change:style", @setupSlides
  
  onRender: =>
    @setupSlides() if @section.get('style') is 'slides'

  setupSlides: (model, style) =>
    if @section.get('style') is 'slides'
      @$el.slick
        infinite: true
        slidesToShow: 1
        slidesToScroll: 1
        initialSlide: 5
      @$el.slick('setPosition')
      @$el.slick('slickNext')
    else
      @$el.slick('unslick')


class CMS.Views.GalleryStyler extends CMS.Views.ItemView
  template: "section_types/gallery_styler"
  events:
    "click a.blocks": "setBlocks"
    "click a.list": "setList"
    "click a.slides": "setSlides"

  setBlocks: () => 
    @model.set "style", "blocks", stickitChange: true
  setList: () => 
    @model.set "style", "list", stickitChange: true
  setSlides: () =>
    @model.set "style", "slides", stickitChange: true


class CMS.Views.GallerySection extends CMS.Views.SectionView
  template: "section_types/gallery"
  styleMenuView: CMS.Views.GalleryStyler

  bindings:
    ":el":
      attributes: [
        name: "class"
        observe: "style"
      ]
    "h2":
      observe: "title"
      updateMethod: "html"
    ".section_body":
      observe: "main_html"
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
    @_image_blocks = new CMS.Views.GalleryImages 
      section: @model
      collection: @_images
    @_image_blocks.render()
    @ui.built.append @_image_blocks.el
    @saveBuiltHtml()
    @$el.on 'input', @saveBuiltHtml



