class CMS.Views.PageBranch extends CMS.Views.ItemView
  template: "pages/branch"
  bindings:
    "a.title":
      observe: "title"
      attributes: [
        observe: "id"
        name: "href"
        onGet: "pageUrl"
      ]

  pageUrl: (id) =>
    "/sites/#{@model.getSite().get "slug"}/pages/#{id}"


class CMS.Views.PagesTree extends CMS.Views.CollectionView
  childView: CMS.Views.PageBranch


class CMS.Views.PagesLayout extends CMS.Views.MenuLayout
  template: "manager/pages"

  onRender: =>
    @model.whenReady () =>
      @stickit()
      @_pages_tree = new CMS.Views.PagesTree
        el: @$el.find(".menu")
      @_pages_tree.render()
      @_sections_layout = new CMS.Views.SectionsLayout
        el: @$el.find("#sections")
        collection: @model.sections
      @_sections_layout.render()

  show: (page, section_uid) =>
    @log "⇒ show", page, section_uid
    @model = page
    @model.whenReady =>
      if section_uid and section = @model.sections.findWhere(uid: section_uid)
        @_sections_layout.show(section)
      else
        @home()

  home: () =>
    # do a default thing
    @log "home"
