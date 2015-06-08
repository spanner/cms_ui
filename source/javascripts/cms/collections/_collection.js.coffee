class CMS.Collection extends Backbone.Collection

  # Our collections always belong to a site, and their model urls are nested within it.
  # except the collection of sites is a root resource.
  #
  initialize: (collection, opts={}) ->
    @_class_name = @constructor.name
    @_path = @_class_name.toLowerCase()
    @_site = opts.site

  getSite: =>
    @_site

  url: =>
    debugger unless @_site
    [@_site.url(), @_path].join('/')
