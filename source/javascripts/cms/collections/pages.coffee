class CMS.Collections.Pages extends CMS.Collection
  model: CMS.Models.Page
  comparator: "path"

  # url: =>
  #   "#{_cms.apiUrl()}pages"

  initialize: (array, opts) ->
    super
    @on 'add', (model, collection, options) =>
      model.once 'sync', () =>
        @sort()
