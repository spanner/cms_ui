class CMS.Views.SectionAdminMenu extends CMS.Views.ItemView
  template: "editor/section_admin_menu"
  
  events:
    "click a.cms-menu": "toggleMenu"
    "click div.properties": "containEvent"
  
  modelEvents:
    "change:section_type": "setSelection"
  
  bindings:
    "input.show_title": "show_title"
  
  onRender: () =>
    @stickit()
    @_menu = @$el.find('.cms-menu')
    @_typer = @$el.find('.section_types')
    for type in CMS.Models.Section.types
      do (type) =>
        a = $("<a class=\"section_type #{type}\" title=\"#{type}\"></a>").appendTo(@_typer)
        a.click (e) =>
          e?.preventDefault()
          @setType(type)
      @setSelection()

  setSelection: () =>
    type = @model.get('section_type') or 'default'
    @_typer.find("a.section_type").removeClass('selected')
    @_typer.find("a.#{type}").addClass('selected')

  toggleMenu: (e) =>
    e?.preventDefault()
    e?.stopPropagation()
    if @_menu.hasClass('open')
      @closeMenu()
    else
      @openMenu()

  openMenu: () =>
    $('.cms-menu').not(@_menu).removeClass('open')
    @_menu.addClass('open')
    $(document).bind "click", @closeMenu
    
  closeMenu: () =>
    $(document).unbind "click", @closeMenu
    @_menu.removeClass('open')

  setType: (type) =>
    @model.set 'section_type', type,
      stickitChange: true


class CMS.Views.Section extends CMS.Views.ItemView
  template: "editor/section"
  tagName: "section"

  events:
    "click": "select"

  bindings:
    ":el":
      observe: "deleted_at"
      visible: "untrue"
      classes:
        selected: "selected"
        destroyed: "destroyed"
    ".wrapper":
      attributes: [
        name: "class"
        observe: "section_type"
        onGet: "wrapperClass"
      ]

  id: -> 
    "section_#{@model.get('id')}"

  initialize: =>
    super
    @model.on "change:section_type", @renderSectionType

  onRender: =>
    super
    @_admin_menu = new CMS.Views.SectionAdminMenu
      model: @model
      el: @$el.find('.cms-section-menu')
    @_admin_menu.render()
    @renderSectionType()
  
  renderSectionType: () =>
    section_type = @model.get('section_type') or 'default'
    wrapper_class_name = section_type.charAt(0).toUpperCase() + section_type.substr(1).toLowerCase() + 'Section'
    wrapper_class = CMS.Views[wrapper_class_name] ? CMS.Views['DefaultSection']
    @_section_wrapper = new wrapper_class
      model: @model
      el: @$el.find('.wrapper')
    @_section_wrapper.render()

  select: =>
    @model.select()

  wrapperClass: (section_type) =>
    section_type ?= 'default'
    "wrapper #{section_type}"


class CMS.Views.Page extends Backbone.Marionette.CompositeView
  childView: CMS.Views.Section
  childViewContainer: "#sections"

  template: () =>
    @model.page_type.get('template')
  
  childViewOptions: () =>
    toolbar: @_toolbar

  bindings:
    "h1":
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

