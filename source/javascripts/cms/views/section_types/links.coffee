## Link blocks and highlights
#
# This is an html-builder: it uses a helper collection view to assemble a list of link blocks
# in a given style. The link blocks will probably show editable features that bind to the individual page,
# but the built block in the section view is only built, not bound.
#
class CMS.Views.BlockPageLink extends CMS.Views.EmbeddedPageView
  template: "pages/block"
  tagName: "div"
  className: "block"

  events:
    "click a.save_page": "saveSubjectPage"
    "click a.block": "stopThat"
    "dragstart a.block": "stopThat"
    "click span.caption": "stopThat"

  ui:
    controls: ".cms-buttons"

  bindings:
    ":el":
      attributes: [
        name: "data-page-id"
        observe: "id"
      ]
    ".title":
      observe: "link_title"
    "a.block":
      attributes: [
        name: "href"
        observe: "path"
      ,
        name: "style"
        observe: "image"
        onGet: "assetBackgroundHalfUrl"
      ]
    "span.caption":
      observe: "block_title"
    "a.save_page":
      observe: "changed"
      visible: true
      visibleFn: "visibleAsInlineBlock"

  onRender: =>
    super
    @_page_picker = new CMS.Views.PagePickerLayout
      model: @model.getSite()
    @_page_picker.render()
    @_page_picker.on 'selected', @setPage
    @_page_picker.$el.appendTo(@ui.controls)
    @_image_picker = new CMS.Views.ImagePickerLayout
      model: @model
    @_image_picker.render()
    @_image_picker.on 'selected', @setImage
    @_image_picker.$el.appendTo(@ui.controls)

  setImage: (image) =>
    @model.set 'image', image
    @sectionChanged()

  setPage: (page) =>
    @model = page
    @fetchAndRender().done =>
      @sectionChanged()

  saveSubjectPage: (e) =>
    e?.preventDefault()
    @model.save()
  
  sectionChanged: () =>
    @$el.trigger('input')


class CMS.Views.NoBlockPages extends Backbone.Marionette.ItemView
  template: "pages/none"


class CMS.Views.PageLinkBlocks extends CMS.Views.EmbeddedPageList
  className: "block_pages"
  childView: CMS.Views.BlockPageLink
  childEvents:
    "remove": "removePage"

  removePage: (e, page) =>
    @collection.remove(page)


class CMS.Views.LinksSection extends CMS.Views.SectionView
  template: "section_types/links"
  content_template: "section_content/link_blocks"

  initialize: ->
    @_pages = new CMS.Collections.Pages
    super

  # All this does is to gather page ids from the old html, then we
  # build new html using the current values for those pages.
  readBuiltHtml: =>
    @_pages.reset()
    if html = @model.get('built_html')
      site = @model.getSite()
      $(html).find('div.block').each (i, block) =>
        if page_id = $(block).data('page-id')
          if page = site.pages.get(page_id)
            @_pages.add page
    @renderContent()

  renderContent: =>
    @ui.built.empty()
    unless @_pages.length
      pages = @model.getPage().childPages()
      @_pages.reset(pages[0..3])
    @_page_blocks = new CMS.Views.PageLinkBlocks
      collection: @_pages
    @_page_blocks.on "children_rendered", () =>
      @ui.built.empty()
      @ui.built.append(@_page_blocks.el)
      @saveBuiltHtml()
    @_page_blocks.render()
    # NB: never bind activated html.
    # Stickit will replace it with identical unlinked elements.
    @$el.on 'input', @saveBuiltHtml