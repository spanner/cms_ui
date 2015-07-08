class CMS.Views.SectionView extends CMS.Views.ItemView
  tagName: "section"
  
  events:
    "click a.delete_section": "deleteSection"
    "click a.add_section": "addSection"
  
  ui:
    built: ".built"
    picture: ".picture"
    content: ".content"
    body: ".section_body"
    editable: ".editable"
    formattable: ".formattable"
    image_picker: ".cms-image-picker"
    video_picker: ".cms-video-picker"
    page_picker: ".cms-page-picker"
    admin_menu: ".cms-section-menu"
    style_menu: ".cms-style-menu"

  onRender: =>
    @sectionMenu()
    @styleMenu()
    if @model.get('built_html')
      @readBuiltHtml()
    else
      @build()
    @ui.editable.attr("contenteditable", "plaintext-only")
    @ui.formattable.attr("contenteditable", "true")
    super

  # returning false from renderContent, eg because there is no content template
  # will short-circuit the building procedure.
  #
  renderContent: () =>
    if template = @getContentTemplate()
      @ui.built.html _cms.render(template, {}, @)
    else
      @ui.built.html ""

  build: () =>
    @renderContent() and @saveBuiltHtml()

  readBuiltHtml: () =>
    # noop here
    # this is the place to retrieve data attributes (sort order, page selection)
    # from the built html and restore UI state for onward editing.

  saveBuiltHtml: () =>
    if html = @ui.built.html()
      @model.set 'built_html', @cleanHtml(html), stickitChange: true

  getContentTemplate: () =>
    @getOption('content_template')

  imageOrVideo: (size, options={}) =>
    @ui.picture.empty()
    options = _.extend options,
      model: @model
      el: @ui.picture
      size: size
    @_image_or_video = new CMS.Views.ImageOrVideo options
    @_image_or_video.render()

  sectionMenu: =>
    @_section_menu = new CMS.Views.SectionAdminMenu
      model: @model
      el: @ui.admin_menu
    @_section_menu.render()

  pagePicker: () =>
    unless @_page_picker
      @_page_picker = new CMS.Views.PagePickerLayout
        model: @model.getSite()
        el: @ui.page_picker
      @_page_picker.render()
      @_page_picker.on 'selected', @setPage

  setPage: (page) =>
    @model.set('subject_page', page)

  videoPicker: () =>
    video_picker = new CMS.Views.VideoPickerLayout
      model: @model
      el: @ui.video_picker
    video_picker.render()
    video_picker.on 'selected', @setVideo

  setVideo: (video) =>
    @model.set('video', video)

  imagePicker: () =>
    image_picker = new CMS.Views.ImagePickerLayout
      model: @model
      el: @ui.image_picker
    image_picker.render()
    image_picker.on 'selected', @setImage

  setImage: (image) =>
    @model.set('image', image)

  styleMenu: () =>
    if style_menu_class = @getOption('styleMenuView')
      @_styler = new style_menu_class
        model: @model
        el: @ui.style_menu
      @_styler.render()
      @_styler.on "styled", @setStyle
  
  setStyle: (style) =>
    @model.set('style', style)

  deleteSection: () =>
    @model?.destroyReversibly()

  addSection: () =>
    pos = (@model.get('position') ? 0)
    above = @model.collection.filter (s) -> s.get('position') > pos
    _.each above, (s, i) ->
      s.set('position', s.get('position') + 1)
    @model.collection.add
      page_id: @model.get('page_id')
      position: pos + 1
      section_type: 'default'

  cleanHtml: (html, options) =>
    @_cleaner ?= $('<div>')
    @_cleaner.html(html)
    @_cleaner.find('.cms-controls').remove()
    @_cleaner.find('.cms-buttons').remove()
    @_cleaner.find('.editable').removeClass('editable')
    @_cleaner.find('.formattable').removeClass('formattable')
    @_cleaner.find('[data-placeholder]').removeAttr('data-placeholder')
    @_cleaner.find('[contenteditable]').removeAttr('contenteditable')
    cleaned = @_cleaner.html()
    cleaned



## Subject pages
#
# Some section types are for selecting and linking to other pages, for which we need an embedded
# representation that can fetch itself and set up the lazy-properties that we use for linking.
# Precis, link title, image etc are all derived from other content at the point where they are
# first needed, then independently editable through the pages on which they appear.
#
class CMS.Views.EmbeddedPageView extends CMS.Views.ItemView

  # returns a promise that will be resolved when rendering finishes
  fetchAndRender: =>
    @_render_promise = $.Deferred()
    @model.load().then(@renderWhenFetched)
    @_render_promise

  renderWhenFetched: =>
    @model.setLazyProperties()
    @render()
    if image = @model.get('image')
      image_viewer = new CMS.Views.Image
        model: image
        size: 'half'
        el: @ui.picture
      image_viewer.render()
    @_render_promise.resolve(@el)


class CMS.Views.EmbeddedPageList extends CMS.Views.CollectionView
  tagName: "div"

  onRender: () =>
    promises = @children.map (child) ->
      child.fetchAndRender()
    $.when(promises...).done (results...) =>
      @trigger "children_rendered", results