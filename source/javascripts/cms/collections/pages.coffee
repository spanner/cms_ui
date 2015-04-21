class CMS.Collections.Pages extends Backbone.Collection
  url: =>
    "#{_cms.apiUrl()}pages"
