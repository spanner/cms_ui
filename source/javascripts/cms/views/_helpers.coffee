class CMS.Views.ListedSectionType extends Backbone.Marionette.ItemView
  template: "section_types/listed"
  tagName: 'li'
  events:
    "click a": "select"
    
  bindings:
    ":el":
      classes: 
        "selected": "selected"
    "a":
      observe: "name"
      attributes: [
        name: "class"
        observe: "slug"
      ]
    
  onRender: () =>
    @stickit()
    
  select: () =>
    @model.select()


class CMS.Views.SectionTypeList extends CMS.Views.MenuView
  template: "section_types/picker"
  childView: CMS.Views.ListedSectionType


class CMS.Views.SectionAdminMenu extends CMS.Views.MenuLayout
  template: "sections/section_type_menu"
  menuView: CMS.Views.SectionTypeList
  
  # we could bind a section type icon here
  bindings: {}

  initialize: ->
    slug = @model.get('section_type') or 'default'
    @collection = new CMS.Collections.SectionTypes
    @collection.findWhere(slug: slug)?.select()
    @collection?.on "change:selected", @setType
    _cms.vent.on "reset_menus", @close

  setType: =>
    if section_type = @collection.findWhere(selected: true)
      @model.set 'section_type', section_type.get('slug')


class CMS.Views.ListedAssetView extends CMS.Views.ItemView
  ui:
    filefield: 'input[type="file"]'
    img: 'img'

  events:
    "click a.delete": "deleteModel"
    "click a.preview": "select"
    "change input[type='file']": "getPickedFile"

  bindings:
    "a.preview":
      attributes: [
        name: 'style'
        observe: 'thumb_url'
        onGet: "backgroundStyle"
      , 
        name: "class"
        observe: "provider"
        onGet: "providerClass"
      ]
    ".file_size":
      observe: "file_size"
      onGet: "inBytes"
    ".file_type":
      observe: "file_type"
      onGet: "inBytes"
    ".width":
      observe: "width"
      onGet: "inPixels"
    ".height":
      observe: "height"
      onGet: "inPixels"
    ".duration":
      observe: "duration"
      onGet: "inTime"
    ".progress":
      observe: "progressing"
      visible: true
    ".progress bar":
      observe: "progress"
      update: "showProgress"

  onRender: =>
    @stickit()
    @popIfNewAndShowing()

  deleteModel: (e) =>
    e?.preventDefault()
    @model.remove()

  popIfNewAndShowing: () =>
    @clickFileField() if @model.isNew() and not @model.get('file')

  clickFileField: (e) =>
    @ui.filefield.trigger('click')

  getPickedFile: (e) =>
    if files = @ui.filefield[0].files
      @readLocalFile files[0]

  getDroppedFile: (e) =>
    @dragOut(e)
    if files = e.originalEvent.dataTransfer.files
      @readLocalFile files[0]

  readLocalFile: (file) =>
    if file?
      if @fileOk(file.name, file.size)
        @model.startProgress()
        #...and show a loading bar within the image box
        reader = new FileReader()
        reader.onprogress = (e) => 
          @model.setProgress(e)
        reader.onloadend = () =>
          @model.finishProgress()
          @setFile reader.result, file
        reader.readAsDataURL(file)

  setFile: (data, file) =>
    @model.set
      file: data
      file_name: file.name
      file_size: file.size
      file_type: file.type
    @select()
    @model.save()

  fileOk: (filename, filesize) =>
    @fileNameOk(filename, filesize) and @fileSizeOk(filename, filesize)

  fileSizeOk: (filename, filesize) =>
    true

  fileNameOk: (filename, filesize) =>
    true

  complain: (error, filename, filesize) =>
    console.log "error"
    
  select: (e) =>
    e?.preventDefault?()
    @trigger 'selected'

  # drop event handlers
  
  dragIn: (e) =>
  dragOut: (e) =>
  containEvent: (e) =>

  # onGet formatters

  inBytes: (value) =>
    if value
      if value > 1048576
        mb = Math.floor(value / 10485.76) / 100
        "#{mb}MB"
      else
        kb = Math.floor(value / 1024)
        "#{kb}KB"
    else
      ""

  inPixels: (value) =>
    "#{value ? 0}px"

  inTime: (value=0) =>
    seconds = parseInt(value, 10)
    if seconds >= 3600
      minutes = Math.floor(seconds / 60)
      [Math.floor(minutes / 60), minutes % 60, seconds % 60].join(':')
    else
      [Math.floor(seconds / 60), seconds % 60].join(':')

  providerClass: (provider) =>
    "yt" if provider is "YouTube"

class CMS.Views.AssetsListView extends CMS.Views.MenuView
  events:
    "click a.detach": "detachAsset"
    "click a.add_item": "addAsset"
    "click a.import": "importAsset"

  childEvents:
    'selected': 'select'
    
  addAsset: =>
    @collection.add
      site_id: @collection.getSite().id

  detachAsset: =>
    @trigger "selected", null

  select: (view) =>
    @trigger 'selected', view.model


  importAsset: =>
    if remote_url = @$el.find('input.remote_url').val()
      console.log "import", remote_url
      @collection.create
        site_id: @collection.getSite().id
        remote_url: remote_url

class CMS.Views.ListedVideo extends CMS.Views.ListedAssetView
  template: "videos/listed"
  tagName: "li"


class CMS.Views.VideosList extends CMS.Views.AssetsListView
  template: "videos/list"
  childView: CMS.Views.ListedVideo
  bindings:
    "li.detach":
      observe: "video"
      visible: true


class CMS.Views.VideoPickerLayout extends CMS.Views.MenuLayout
  template: "videos/picker"
  menuView: CMS.Views.VideosList

  initialize: ->
    @collection = @model.videos
    super

  onOpen: =>
    super
    @_menu_view.on "selected", @select

  select: (model) =>
    @trigger "selected", model
    @close()

class CMS.Views.ListedImage extends CMS.Views.ListedAssetView
  template: "images/listed"
  tagName: "li"


class CMS.Views.ImagesList extends CMS.Views.AssetsListView
  template: "images/list"
  childView: CMS.Views.ListedImage
  bindings:
    "li.detach":
      observe: "image"
      visible: true


class CMS.Views.ImagePickerLayout extends CMS.Views.MenuLayout
  template: "images/picker"
  menuView: CMS.Views.ImagesList

  initialize: (data, options={}) ->
    @collection = @model.images
    super

  onOpen: =>
    super
    @_menu_view.on "selected", @select

  select: (model) =>
    @trigger "selected", model
    @close()


class CMS.Views.ListedPage extends CMS.Views.ItemView
  template: "pages/listed"
  tagName: "li"
  
  events: "click a": "select"
  bindings: 
    "span.title": "title"
    "span.path": "path"
    "span.descent":
      observe: "path"
      onGet: "showDescent"
      updateMethod: 'html'

  select: () =>
    @trigger('selected')


class CMS.Views.PagesList extends CMS.Views.MenuView
  template: "pages/list"
  childView: CMS.Views.ListedPage

  childEvents:
    'selected': 'select'

  select: (view) =>
    @trigger('selected', view.model)


class CMS.Views.PagePickerLayout extends CMS.Views.MenuLayout
  template: "pages/picker"
  menuView: CMS.Views.PagesList

  initialize: (data, options={}) ->
    @collection = @model.pages
    super

  onOpen: =>
    super
    @_menu_view.on "selected", @select

  select: (model) =>
    @trigger "selected", model
    @close()


class CMS.Views.MediumBig extends MediumEditor.extensions.button
  aria: "big"
  name: "big"
  _class: "bigtext"
  contentDefault: '<span>Big</span>'
  style:
    prop: "font-size"
    value: "1.3em"

  constructor: (@_iframe) ->
    super
    @_applier = rangy.createClassApplier(@_class)

  action: (e) =>
    selection = rangy.getSelection(@_iframe)
    @_applier.toggleSelection(selection)
    $(@base.getFocusedElement()).trigger "change"

    if @button
      nodes = MediumEditor.selection.getSelectedElements(@_iframe)
      if @isAlreadyApplied()
        @setActive()
      else
        @setInactive()
    null

  isAlreadyApplied: (node) =>
    nodes = MediumEditor.selection.getSelectedElements(@_iframe)
    _.filter(nodes, (node) => $(node).hasClass(@_class)).length > 0
