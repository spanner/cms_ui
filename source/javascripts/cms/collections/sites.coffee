class CMS.Collections.Sites extends Backbone.Collection
  url: =>
    "#{_cms.apiUrl()}sites"
