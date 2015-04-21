class CMS.Collections.Sections extends Backbone.Collection
  url: =>
    "#{_cms.apiUrl()}sections"
