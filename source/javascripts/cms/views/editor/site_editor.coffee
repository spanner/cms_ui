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
    "tab": "#tab"
    "controls": "#site_controls"

  events:
    "click a[data-tab]": "showTab"

  bindings:
    "span.title": "title"
    "link":
      attributes: [
        name: "href"
        observe: "template"
        onGet: "templateStylesheetLink"
      ]

  onRender: =>
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
      "/stylesheets/templates/#{template_name}.css"
