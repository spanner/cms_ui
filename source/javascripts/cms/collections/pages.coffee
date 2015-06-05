class CMS.Collections.Pages extends Cms.Collection
  model: CMS.Models.Page
  comparator: "path"

  initialize: (array, opts) ->
    @site = opts.site
    @on 'add', (model, collection, options) =>
      model.set('site_id', @site.get('id'))
      model.once 'sync', () =>
        @sort()
