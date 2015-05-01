class CMS.Models.Section extends CMS.Model

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
