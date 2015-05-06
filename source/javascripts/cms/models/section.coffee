class CMS.Models.Section extends CMS.Model
  savedAttributes: ["page_id"]

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
