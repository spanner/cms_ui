class CMS.Views.NavLinkRenderer extends CMS.Views.ItemView
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


class CMS.Views.NavigationRenderer extends CMS.Views.CollectionView
  tagName: "nav"
  childView: CMS.Views.NavLinkRenderer


class CMS.Views.HeaderRenderer extends CMS.Views.ItemView
  template: false
  tagName: 'header'
  
  onRender: () =>
    @$el.html @model.get('header')
    @_nav = new CMS.Views.NavigationRenderer
      collection: @model.nav_pages
      el: @$el.find('nav')
    @_nav.render()


class CMS.Views.FooterRenderer extends CMS.Views.ItemView
  template: false
  tagName: 'footer'
  
  onRender: () =>
    @$el.html @model.get('footer')
    @_nav = new CMS.Views.NavigationRenderer
      collection: @model.nav_pages
      el: @$el.find('nav')
    @_nav.render()

