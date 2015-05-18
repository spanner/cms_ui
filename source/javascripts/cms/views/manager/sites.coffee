class CMS.Views.SiteManagerLayout extends CMS.Views.MenuLayout
  template: "manager/site"
  
  bindings:
    '.header a.title':
      observe: "title"
      updateMethod: "html"
      attributes: [
        name: "class"
        observe: ["changed", "published_at", "updated_at"]
        onGet: "siteStatus"
      ]

  showing: =>
    showing = $('#ui').hasClass('shelved')
    showing

  open: =>
    $('#ui').addClass('shelved')

  close: =>
    $('#ui').removeClass('shelved')

  siteStatus: ([changed, published_at, updated_at]=[]) =>
    if changed
      "site title save_me"
    else if (updated_at > published_at)
      "site title "
    else
      "site title publish_me"
      