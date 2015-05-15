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
    @$el.html @model.get('header')
    @_nav = new CMS.Views.Navigation
      collection: @model.nav_pages
      el: @$el.find('nav')
    @_nav.render()


class CMS.Views.Footer extends Backbone.Marionette.ItemView
  template: false
  tagName: 'footer'
  
  onRender: () =>
    @$el.html @model.get('footer')
    @_nav = new CMS.Views.Navigation
      collection: @model.nav_pages
      el: @$el.find('nav')
    @_nav.render()

