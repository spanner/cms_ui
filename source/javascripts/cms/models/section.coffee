class CMS.Models.Section extends CMS.Model
  populate: =>
    unless @get("populated")
      @fetch().done (data) =>
        @set 'populated', true

  getPage: =>
    @collection?.page

  getSite: =>
    @getPage()?.getSite()
