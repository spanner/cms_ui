class CMS.Collections.Pages extends Backbone.Collection
  model: CMS.Models.Page

  initialize: (array,opts) ->
    @site = opts.site

  url: =>
    "#{_cms.apiUrl()}pages"
