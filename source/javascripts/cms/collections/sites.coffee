class CMS.Collections.Sites extends Backbone.Collection
  model: CMS.Models.Site
  url: =>
    "#{_cms.apiUrl()}sites"
