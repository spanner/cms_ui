class CMS.Views.SiteControls extends CMS.Views.ItemView
  template: "manager/site_controls"

  events:
    "click a.save_page": "savePage"
    "click a.publish_page": "publishPage"

  bindings: 
    "a.save_site":
      observe: "changed"
      visible: true
      visibleFn: "visibleAsInlineBlock"
    "a.publish_site":
      observe: ["changed", "published_at", "updated_at"]
      visible: "ifPublishable"
      visibleFn: "visibleAsInlineBlock"

  savePage: (e) =>
    e?.preventDefault()
    @model.save()

  ifPublishable: ([changed, published_at, updated_at]=[]) =>
    not changed and (not published_at or updated_at > published_at)

  publishPage: (e) =>
    e?.preventDefault()
    @model.publish()


class CMS.Views.NavLink extends CMS.Views.ItemView
  template: false
  tagName: "a"
  className: "nav"
  bindings: 
    ':el':
      observe: ["nav_name", "title"]
      onGet: "thisOrThat"
      attributes: [
        name: 'href'
        observe: 'path'
      ]

  onRender: () =>
    @$el.attr "contenteditable", "true"
    super


class CMS.Views.Navigation extends CMS.Views.CollectionView
  tagName: "nav"
  childView: CMS.Views.NavLink


class CMS.Views.Header extends Backbone.Marionette.ItemView
  template: false
  tagName: 'header'
  
  onRender: () =>
    @model.whenReady =>
      @$el.html @model.get('header')
      @_nav = new CMS.Views.Navigation
        collection: @model.nav_pages
        el: @$el.find('nav')
      @_nav.render()


class CMS.Views.Footer extends Backbone.Marionette.ItemView
  template: false
  tagName: 'footer'
  
  onRender: () =>
    @model.whenReady =>
      @$el.html @model.get('footer')
      @_nav = new CMS.Views.Navigation
        collection: @model.nav_pages
        el: @$el.find('nav')
      @_nav.render()


class CMS.Views.SiteEditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/site_editor"
  regions: 
    "css": "#style"
    "js": "#script"
    "config": "#config"
    "controls": "#site_controls"

  events:
    "click a[data-tab]": "showTab"

  bindings:
    "span.title": "title"

  onRender: =>
    @stickit()
    $.site = @model
    @model.whenReady =>
      @_css_view = new CMS.Views.CSS
        model: @model
      @getRegion('css').show(@_css_view)

      @_js_view = new CMS.Views.JS
        model: @model
      @getRegion('js').show(@_js_view)

      @_config_view = new CMS.Views.SiteConfig
        model: @model
      @getRegion('config').show(@_config_view)

      @_site_controls = new CMS.Views.SiteControls
        model: @model
      @getRegion('controls').show(@_site_controls)

  showTab: (e) =>
    $el = $(e.currentTarget)
    tab = $el.data("tab")
    console.log 'showTab', tab, @$el.find("##{tab}")
    unless $el.hasClass("current")
      @$el.find(".current").removeClass("current")
      @$el.find("##{tab}").addClass("current")
      $el.addClass("current")
