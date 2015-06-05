class CMS.Collections.Sites extends CMS.Collection
  model: CMS.Models.Site

  url: =>
    "#{_cms.apiUrl()}sites"
