class CMS.Views.SectionAdminMenu extends CMS.Views.ItemView
  template: "editor/section_admin_menu"
  
  events:
    "click a.cms-menu-head": "toggleMenu"
  
  modelEvents:
    "change:section_type": "setSelection"
  
  onRender: () =>
    @stickit()
    @_menu = @$el.find('.cms-menu-body')
    @_typer = @$el.find('.section_types')
    
    for type in CMS.Models.Section.types
      do (type) =>
        a = $("<a class=\"cms-section-type #{type}\" title=\"#{type}\">#{type}</a>").appendTo(@_typer)
        a.click (e) =>
          e?.preventDefault()
          @setType(type)
      @setSelection()

  setSelection: () =>
    type = @model.get('section_type') or 'default'
    @_typer.find("a.section_type").removeClass('selected')
    @_typer.find("a.#{type}").addClass('selected')

  toggleMenu: (e) =>
    if @_menu.hasClass('open')
      @closeMenu(e)
    else
      @openMenu(e)

  openMenu: (e) =>
    e?.preventDefault()
    @_menu.addClass('open')
    @_menu.parents('.cms-controls').addClass('open')
    $(document).on "click", @closeMenu
    
  closeMenu: (e) =>
    e?.preventDefault()
    $(document).off "click", @closeMenu
    @_menu.removeClass('open')
    @_menu.parents('.cms-controls').removeClass('open')

  setType: (type) =>
    @model.set 'section_type', type,
      stickitChange: true


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
    @_section_menu = new CMS.Views.SectionAdminMenu
      model: @model
      el: @$el.find('.cms-section-menu')
    @_section_menu.render()

  select: =>
    @model.select()

  sectionClass: (section_type) =>
    section_type or 'default'




class CMS.Views.Page extends Backbone.Marionette.CompositeView
  childView: CMS.Views.Section
  childViewContainer: "#sections"

  template: () =>
    @model.page_type.get('html')
  
  childViewOptions: () =>
    toolbar: @_toolbar

  bindings:
    "h1.pagetitle":
      observe: "title"
      updateMethod: "html"
      classes: 
        "hidden": "hide_title"
    ".hide_title": "hide_title"
    "#standfirst":
      observe: "introduction"
      updateMethod: "html"
      classes:
        "hidden": "hide_introduction"
    ".hide_introduction": "hide_introduction"

  onRender: () =>
    @stickit()
    $.page = @model


class CMS.Views.PageHead extends Backbone.Marionette.ItemView
  template: false

  bindings:
    "style": "css"

  onRender: =>
    @model.whenReady =>
      @$el.append('<style />')
      @$el.append '<link rel="stylesheet" href="/stylesheets/cms-base.css" type="text/css" />',
      @stickit()


class CMS.Views.PageEditorLayout extends Backbone.Marionette.LayoutView
  tagName: "iframe"
  template: false

  onRender: =>
    # @_toolbar?.destroy()
    @model.whenReady =>
      html = @model.getSite()?.get('html')
      doc = @el.contentWindow.document
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

      # @_toolbar = new MediumEditor '.editable',
      #   elementsContainer: $("#rte").get(0)
      #   fixedToolbar: true
      #   updateOnEmptySelection: true
      #   disablePlaceholders: true
      #   updateOnEmptySelection: true

