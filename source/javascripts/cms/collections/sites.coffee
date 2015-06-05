class CMS.Collections.Sites extends Cms.Collection
  model: CMS.Models.Site

  url: =>
    "#{_cms.apiUrl()}sites"
