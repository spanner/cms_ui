class CMS.Collections.Pages extends CMS.Collection
  model: CMS.Models.Page
  comparator: (model) ->
    -model.get('created_at')

  initialize: (array, opts) ->
    super
    @on 'add', (model, collection, options) =>
      model.once 'sync', () =>
        @sort()
