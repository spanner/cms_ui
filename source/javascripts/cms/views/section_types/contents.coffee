## Contents block
#
# This is purely an html-builder: it uses a helper collection view to assemble a list of link blocks
# in a given style. The link blocks will probably show editable features that bind to the individual page,
# but the built block in the section view is only built, not bound.
#
class CMS.Views.ChildPage extends CMS.Views.EmbeddedPageView
  template: "pages/child"
  tagName: "div"
  className: "child-page"

  events:
    "click a.save_page": "saveSubjectPage"

  bindings: 
    ":el":
      attributes: [
        name: "data-page-id"
        observe: "id"
      ]
    "a.page":
      attributes: [
        name: "href"
        observe: "path"
      ]
    ".title":
      observe: "link_title"
    ".precis":
      observe: "precis"
      updateMethod: "html"
    "a.save_page":
      observe: "changed"
      visible: true
      visibleFn: "visibleAsInlineBlock"
    "date":
      observe: "published_at"
      onGet: "dayMonthYear"

  ui:
    picture: ".picture"
    controls: ".cms-buttons"

  onRender: =>
    super
    if image = @model.get('image')
      @_image_viewer = new CMS.Views.Image
        model: image
        size: 'half'
        el: @ui.picture
      @_image_viewer.render()
    @_image_picker = new CMS.Views.ImagePickerLayout
      model: @model
    @_image_picker.render()
    @_image_picker.on 'selected', @setImage
    @_image_picker.$el.appendTo(@ui.controls)

  setImage: (image) =>
    @model.set 'image', image
    @_image_viewer.model = image
    @_image_viewer.render()
    @sectionChanged()

  sectionChanged: () =>
    @$el.trigger('input')

  saveSubjectPage: (e) =>
    e?.preventDefault()
    @model.save()

  dayMonthYear: (date) =>
    console.log "dayMonthYear", date
    if date
      date = new Date(date) unless date.getDate
      months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
      [date.getDate(), months[date.getMonth()], date.getFullYear()].join(' ')
    else
      "Unpublished"


class CMS.Views.NoChildPages extends Backbone.Marionette.ItemView
  template: "pages/none"


class CMS.Views.PageChildren extends CMS.Views.EmbeddedPageList
  className: "child_pages"
  childView: CMS.Views.ChildPage

  initialize: () ->
    pages = _.sortBy @model.childPages(), (model) ->
      -model.get('created_at')
    @collection = new CMS.Collections.Pages(pages)


class CMS.Views.ContentsStyler extends CMS.Views.ItemView
  template: "section_types/contents_styler"
  events:
    "click a.previews": "setPreview"
    "click a.blocks": "setBlocks"
    "click a.list": "setList"
    "click a.refresh": "refresh"

  setPreview: () => 
    @model.set "style", "previews", stickitChange: true
  setBlocks: () => 
    @model.set "style", "blocks", stickitChange: true
  setList: () => 
    @model.set "style", "list", stickitChange: true
  refresh: () =>
    @trigger "refresh"


class CMS.Views.ContentsSection extends CMS.Views.SectionView
  template: "section_types/contents"
  styleMenuView: CMS.Views.ContentsStyler

  bindings:
    ":el":
      attributes: [
        name: "class"
        observe: "style"
      ]
    "h2.title":
      observe: "title"
      updateMethod: "html"

  onRender: () =>
    super
    @pagePicker()
    @_styler.on "refresh", @build

  readBuiltHtml: =>
    @build()

  renderContent: () =>
    @_children_view = new CMS.Views.PageChildren
      model: @model.get('subject_page') or @model.getPage()
    @_children_view.on "children_rendered", () =>
      @ui.built.empty()
      @ui.built.append(@_children_view.el)
      @saveBuiltHtml()
    @_children_view.render()

  setPage: (page) =>
    @model.set 'subject_page', page, stickitChange: true
    @model.set('title', page.get('title')) unless @model.get('title')
    @build()
