class CMS.Views.SiteControls extends CMS.Views.ItemView
  template: "manager/site_controls"

  events:
    "click a.save_site": "saveSite"
    "click a.publish_site": "publishSite"

  ui:
    confirmation: "span.confirmation"

  bindings: 
    "a.save_site":
      observe: "changed"
      visible: true
      visibleFn: "visibleAsInlineBlock"
    "a.publish_site":
      observe: ["changed", "published_at", "updated_at"]
      visible: "ifPublishable"
      visibleFn: "visibleAsInlineBlock"

  ifPublishable: ([changed, published_at, updated_at]=[]) =>
    not changed and (not published_at or updated_at > published_at)

  saveSite: (e) =>
    e?.preventDefault()
    @model.save().done () =>
      @confirm "saved"

  publishSite: (e) =>
    e?.preventDefault()
    @model.publish().done () =>
      @confirm "published"
  
  confirm: (message) =>
    @ui.confirmation.stop().text("✓ #{message}").css(display: "inline-block").fadeOut(2000)


class CMS.Views.NavLink extends CMS.Views.ItemView
  template: false
  tagName: "a"
  className: "nav"
  bindings: 
    ':el':
      observe: "nav_name"
      attributes: [
        name: 'href'
        observe: 'path'
      ]

  onRender: () =>
    @$el.attr "contenteditable", "true"
    @model.set("nav_name", @model.get("title")) unless @model.get("nav_name")
    super


class CMS.Views.Navigation extends CMS.Views.CollectionView
  tagName: "nav"
  childView: CMS.Views.NavLink


class CMS.Views.Header extends Backbone.Marionette.ItemView
  template: false
  tagName: 'header'
  
  modelEvents:
    "change:header": "renderNav"

  onRender: () =>
    @model.whenReady @renderNav

  renderNav: =>
    @$el.html @model.get('header')
    @_nav = new CMS.Views.Navigation
      collection: @model.nav_pages
      el: @$el.find('nav')
    @_nav.render()


class CMS.Views.Footer extends Backbone.Marionette.ItemView
  template: false
  tagName: 'footer'

  modelEvents:
    "change:footer": "renderNav"

  onRender: () =>
    @model.whenReady @renderNav

  renderNav: =>
    @$el.html @model.get('footer')
    @_nav = new CMS.Views.Navigation
      collection: @model.nav_pages
      el: @$el.find('nav')
    @_nav.render()

class CMS.Views.SiteEditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/site_editor"
  regions:
    "tab": "#tab"
    "controls": "#site_controls"

  events:
    "click a[data-tab]": "showTab"

  bindings:
    "style": "preview_css"
    "span.title": "title"
    "link.fonts":
      attributes: [
        name: "href"
        observe: "font_css_url"
      ]
    "link.template":
      attributes: [
        name: "href"
        observe: "template"
        onGet: "templateStylesheetLink"
      ]
    "script":
      attributes: [
        name: "src"
        observe: "template"
        onGet: "templateJavascriptSrc"
      ]

  onRender: =>
    $.site = @model
    @getRegion('controls').show new CMS.Views.SiteControls
      model: @model
    @model.whenReady =>
      @stickit()
      @showTab()

  showTab: (e) =>
    if e
      $el = $(e.currentTarget)
      tab = $el.data("tab") ? 'config'
    else
      $el = @$el.find('a[data-tab="html"]')
      tab = 'html'
    tab_view_class = switch tab
      when 'css' then CMS.Views.SiteCSS
      when 'js' then CMS.Views.SiteJS
      when 'assets' then CMS.Views.SiteAssets
      when 'config' then CMS.Views.SiteConfig
      else CMS.Views.SiteHtml
    @$el.find('.current').removeClass('current')
    $el.addClass('current')
    tab_view = new tab_view_class
      model: @model
    @getRegion('tab').show(tab_view)
    $.tv = tab_view

  templateStylesheetLink: (template_name) => 
    if template_name
      "/stylesheets/base/#{template_name}.css"

  templateJavascriptSrc: (template_name) => 
    if template_name
      "/javascripts/base/#{template_name}.js"
