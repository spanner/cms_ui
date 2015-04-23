class CMS.Collections.Sections extends Backbone.Collection
  model: CMS.Models.Section
  url: =>
    "#{_cms.apiUrl()}sections"
