class CMS.Collections.Sections extends Backbone.Collection
  model: CMS.Models.Section
  comparator: "position"

  initialize: (array, opts) ->
    @page = opts.page

  url: =>
    "#{_cms.apiUrl()}sections"

  toJSON: =>
    m.toJSON() for m in @models
      
