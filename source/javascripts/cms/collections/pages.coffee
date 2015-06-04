class CMS.Collections.Pages extends Backbone.Collection
  model: CMS.Models.Page
  comparator: "path"

  initialize: (array, opts) ->
    @site = opts.site
    @on 'add', (model, collection, options) =>
      model.set('site_id', @site.get('id'))
      model.once 'sync', () =>
        @sort()
    $.pages = @

  url: =>
    "#{_cms.apiUrl()}pages"
