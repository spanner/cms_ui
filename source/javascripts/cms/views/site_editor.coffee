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

  events:
    "click": "stopThat"
    "dragstart": "stopThat"

  onRender: () =>
    @$el.attr "contenteditable", "true"
    @model.set("nav_name", @model.get("title")) unless @model.get("nav_name")
    super


class CMS.Views.Navigation extends CMS.Views.CollectionView
  tagName: "nav"
  childView: CMS.Views.NavLink


class CMS.Views.Header extends Backbone.Marionette.ItemView
  template: false

  onRender: () =>
    @model.whenLoaded @renderNav

  renderNav: =>
    # @$el.html @model.get('header')
    @_nav = new CMS.Views.Navigation
      collection: @model.nav_pages
      el: @$el.find('nav')
    @_nav.render()


class CMS.Views.Footer extends Backbone.Marionette.ItemView
  template: false

  onRender: () =>
    @model.whenLoaded @renderNav

  renderNav: =>
    # @$el.html @model.get('footer')
    @_nav = new CMS.Views.Navigation
      collection: @model.nav_pages
      el: @$el.find('nav')
    @_nav.render()


class CMS.Views.SiteEditorLayout extends Backbone.Marionette.LayoutView
  template: "layouts/site_editor"
  regions:
    "tab": "#cms-config-body"
    "controls": "#site_controls"

  events:
    "click a[data-tab]": "showTab"

  bindings:
    "style": "css"
    "span.title": "title"
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
    @model.whenLoaded =>
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


class CMS.Views.SiteJS extends CMS.Views.ItemView
  @mixin 'text'
  template: "sites/js"

  events:
    "paste #js": "paste"

  bindings:
    "#js": "coffee"
    "a.preview":
      observe: ["original_coffee", "coffee", "original_js", "js"]
      visible: "notTheSameOrNotTheSame"
      visibleFn: "visibleAsInlineBlock"

  ui:
    textarea: "textarea#js"

  onRender: =>
    @stickit()
    _.delay @show, 2

  show: =>
    unless @editor
      @editor = CodeMirror.fromTextArea @ui.textarea[0],
        mode: @model.get("js_preprocessor") ? "coffeescript"
        theme: "spanner"
        showCursorWhenSelecting: true
        lineNumbers: true
        tabSize: 2
        extraKeys:
          "Cmd-Enter": @preview
          "Ctrl-Enter": @preview
          "Cmd-S": @save
          "Ctrl-S": @save
      @model.on "change:js_preprocessor", (model, value) ->
        @editor.setOption mode: value

      @editor.on "change", =>
        @ui.textarea.val @editor.getValue()
        @ui.textarea.trigger "change"

  preview: =>
    @model.previewJS()


class CMS.Views.SiteCSS extends CMS.Views.ItemView
  @mixin 'text'
  template: "sites/css"

  events:
    "click a.preview": "previewCSS"
    "paste #css": "paste"

  ui:
    textarea: "textarea#css"
    header_area: "textarea#header"

  bindings:
    "#css": "sass"
    "a.preview":
      observe: ["original_sass", "sass", "original_css", "css"]
      visible: "notTheSameOrNotTheSame"
      visibleFn: "visibleAsInlineBlock"

  onRender: =>
    @stickit()
    _.delay @show, 2

  show: =>
    unless @editor
      @editor = CodeMirror.fromTextArea @ui.textarea[0],
        mode: @model.get("css_preprocessor") ? 'sass'
        theme: "spanner"
        showCursorWhenSelecting: true
        lineNumbers: true
        tabSize: 2
        extraKeys:
          "Cmd-Enter": @preview
          "Ctrl-Enter": @preview
          "Cmd-S": @save
          "Ctrl-S": @save

      @model.on "change:css_preprocessor", (model, value) ->
        @editor.setOption mode: value

      @editor.on "change", =>
        @ui.textarea.val @editor.getValue()
        @ui.textarea.trigger "input"

  preview: =>
    @model.previewCSS()


class CMS.Views.SiteHtml extends CMS.Views.ItemView
  @mixin 'text'
  template: "sites/html"

  events:
    "click a.preview": "previewHTML"

  bindings:
    "#haml": "haml"
    "a.preview":
      observe: ["original_haml", "haml", "original_html", "html"]
      visible: "notTheSameOrNotTheSame"
      visibleFn: "visibleAsInlineBlock"

  ui:
    textarea: "textarea#haml"

  onRender: =>
    @stickit()
    _.delay @show, 2

  show: =>
    unless @editor
      @editor = CodeMirror.fromTextArea @ui.textarea[0],
        mode: "haml"
        theme: "spanner"
        showCursorWhenSelecting: true
        lineNumbers: true
        tabSize: 2
        extraKeys:
          "Cmd-Enter": @preview
          "Ctrl-Enter": @preview
          "Cmd-S": @save
          "Ctrl-S": @save

      @editor.on "change", =>
        @ui.textarea.val @editor.getValue()
        @ui.textarea.trigger "change"

  preview: =>
    @model.previewHTML()


class CMS.Views.SiteConfig extends Backbone.Marionette.ItemView
  template: "sites/config"

  bindings:
    ".title": "title"
    ".domain": "domain"

  onRender: =>
    @stickit()


class CMS.Views.SiteAssets extends Backbone.Marionette.ItemView
  template: "sites/assets"

  onRender: (e) =>
    _.delay @show, 2

  show: =>
