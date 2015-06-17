class CMS.Views.Section extends CMS.Views.ItemView
  template: false
  tagName: "section"

  events:
    "click": "select"

  bindings:
    ":el":
      observe: "deleted_at"
      visible: "untrue"
      attributes: [
        name: "class"
        observe: "section_type"
        onGet: "sectionClass"
      ]

  id: -> 
    "section_#{@model.get('id')}"

  initialize: =>
    super
    @model.on "change:section_type", @renderSectionType

  onRender: =>
    super
    @renderSectionType()

  renderSectionType: () =>
    section_type = @model.get('section_type') or 'default'
    wrapper_class_name = section_type.charAt(0).toUpperCase() + section_type.substr(1).toLowerCase() + 'Section'
    wrapper_class = CMS.Views[wrapper_class_name] ? CMS.Views['DefaultSection']
    @_section_wrapper = new wrapper_class
      model: @model
      el: @$el
    @_section_wrapper.render()

  select: =>
    @model.select()

  sectionClass: (section_type) =>
    section_type or 'default'




class CMS.Views.Page extends Backbone.Marionette.CompositeView
  childView: CMS.Views.Section
  childViewContainer: "#sections"

  template: () =>
    @model.get('page_type')?.get('html')
  
  childViewOptions: () =>
    toolbar: @_toolbar
    
  ui:
    title: "h1.pagetitle"
    intro: "#standfirst"

  bindings:
    "h1.pagetitle":
      observe: "title"
    "#standfirst":
      observe: "introduction"
      updateMethod: "html"

  onRender: () =>
    console.log "rendering introduction", @model.get('introduction')
    @ui.title.attr('contenteditable', 'plaintext-only').attr('data-placeholder', 'Page title')
    @ui.intro.attr('contenteditable', 'true').attr('data-placeholder', 'Optional introduction to the page')
    $.page = @model
    @stickit()


class CMS.Views.PageHead extends Backbone.Marionette.ItemView
  template: false

  bindings:
    "style": "css"

  onRender: =>
    @model.whenReady =>
      @$el.append('<style />')
      @$el.append '<link rel="stylesheet" href="/stylesheets/cms-editor.css" type="text/css" />',
      @$el.append '<script src="/javascripts/cms-base.js" type="text/javascript" />',
      @stickit()


class CMS.Views.PageEditorLayout extends Backbone.Marionette.LayoutView
  tagName: "iframe"
  template: false

  onRender: =>
    @model.whenReady =>
      html = @model.getSite()?.get('html')
      iwindow = @el.contentWindow
      doc = iwindow.document
      doc.open()
      doc.write(html)
      $(doc.head).append("<script>#{@model.getSite()?.get("js")}</script>")
      doc.close()

      @_page_head_view = new CMS.Views.PageHead
        model: @model.getSite()
        el: $(doc.head)
      @_page_head_view.render()

      @_page_header = new CMS.Views.Header
        model: @model.getSite()
        el: $(doc.body).find('header')
      @_page_header.render()

      @_page_footer = new CMS.Views.Footer
        model: @model.getSite()
        el: $(doc.body).find('footer')
      @_page_footer.render()

      @_page_view = new CMS.Views.Page
        model: @model
        collection: @model.sections
        el: $(doc.body).find('main')
      @_page_view.render()

      @_toolbar = new MediumEditor '.formattable',
        contentWindow: iwindow
        ownerDocument: doc
        disablePlaceholders: true
        updateOnEmptySelection: true
