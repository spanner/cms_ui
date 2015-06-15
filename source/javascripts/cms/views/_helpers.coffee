class CMS.Views.ListedSectionType extends Backbone.Marionette.ItemView
  template: "section_types/listed"
  tagName: 'li'
  events:
    "click a": "setSelected"
    
  bindings:
    "a":
      observe: "name"
      attributes: [
        name: "class"
        observe: "name"
      ]
    
  onRender: () =>
    @stickit()
    
  select: () =>
    @model.select()


class CMS.Views.SectionTypeList extends CMS.Views.MenuView
  template: "section_types/picker"
  tagName: 'ul'
  childView: CMS.Views.ListedSectionType


class CMS.Views.SectionAdminMenu extends CMS.Views.MenuLayout
  template: "sections/section_type_menu"
  menuView: CMS.Views.SectionTypeList
  
  # we could bind a section type icon here
  bindings: {}

  initialize: ->
    @collection = new CMS.Collections.SectionTypes
    name = @model.get('section_type') or 'default'
    @collection.findWhere(name: name).select()
    @collection?.on "change:selected", @setType
    _cms.vent.on "reset_menus", @close

  setType: =>
    if section_type = @collection.findWhere(selected: true)
      @model.set 'section_type', section_type.get('name')


class CMS.Views.ListedAssetView extends Backbone.Marionette.ItemView
  ui:
    filefield: 'input[type="file"]'
    img: 'img'

  events:
    "click a.delete": "deleteModel"
    "click a.preview": "select"
    "change input[type='file']": "getPickedFile"

  bindings:
    "a.preview":
      observe: "preview_url"
      update: "setBackground"
    ".file_size":
      observe: "file_size"
      onGet: "inBytes"
    ".file_type":
      observe: "filet_ype"
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

  onRender: =>
    @stickit()
    @clickFileField() if @model.isNew()

  deleteModel: (e) =>
    e?.preventDefault()
    @model.remove()

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
        job = _cms.job("Reading file")
        #...and show a loading bar within the image box
        reader = new FileReader()
        reader.onprogress = (e) -> 
          job.setProgress(e)
        reader.onloadend = () =>
          @setFile reader.result, file
          job.complete()
        reader.readAsDataURL(file)

  setFile: (data, file) =>
    preview_data = @getPreview(data, file)
    @model.set
      file: data
      file_type: data.type
      preview_url: preview_data
    @select()

  getPreview: (data, file) =>
    data

  setBackground: ($el, val, m, opts) =>
    $el.css "background-image", "url(#{val})"

  fileOk: (filename, filesize) =>
    @fileNameOk(filename, filesize) and @fileSizeOk(filename, filesize)

  fileSizeOk: (filename, filesize) =>
    true

  fileNameOk: (filename, filesize) =>
    true

  complain: (error, filename, filesize) =>
    console.log "error"
    
  select: (e) =>
    e?.preventDefault()
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



class CMS.Views.AssetsListView extends CMS.Views.MenuView
  childEvents:
    'selected': 'select'

  addItem: =>
    @collection.add
      site_id: @collection.getSite().id

  select: (view) =>
    console.log "list select!", view
    @trigger 'selected', view.model

class CMS.Views.ListedVideo extends CMS.Views.ListedAssetView
  template: "videos/listed"
  tagName: "li"

class CMS.Views.VideosList extends CMS.Views.AssetsListView
  template: "videos/list"
  childView: CMS.Views.ListedVideo

class CMS.Views.VideoPickerLayout extends CMS.Views.MenuLayout
  template: "videos/picker"
  menuView: CMS.Views.VideosList

  initialize: ->
    @collection = @model.videos
    super

  onRender: =>
    super
    @_menu_view.on "selected", @select

  select: (model) =>
    console.log "video picker select!", model
    @trigger "selected", model


class CMS.Views.ListedImage extends CMS.Views.ListedAssetView
  template: "images/listed"
  tagName: "li"

class CMS.Views.ImagesList extends CMS.Views.AssetsListView
  template: "images/list"
  childView: CMS.Views.ListedImage

class CMS.Views.ImagePickerLayout extends CMS.Views.MenuLayout
  template: "images/picker"
  menuView: CMS.Views.ImagesList

  initialize: (data, options={}) ->
    @collection = @model.images
    @target = options.targetEl
    super

  onRender: =>
    super
    @_menu_view.on "selected", @select

  select: (model) =>
    console.log "image picker select!", model
    @trigger "selected", model



