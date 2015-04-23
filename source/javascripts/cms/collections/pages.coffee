class CMS.Collections.Pages extends Backbone.Collection
  model: CMS.Models.Page
  url: =>
    "#{_cms.apiUrl()}pages"
