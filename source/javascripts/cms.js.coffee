#= require hamlcoffee
#= require lib/jquery
#= require lib/jquery.cookie
#= require lib/underscore
#= require lib/underscore.string
#= require lib/backbone
#= require lib/backbone.cocktail
#= require lib/backbone.marionette
#= require lib/backbone.stickit

#= require lib/utilities

#= require ./cms/application
#= require ./cms/router
#= require ./cms/config
#= require ./cms/view_mixins

#= require_tree ./templates
#= require_tree ./cms/models
#= require_tree ./cms/collections
#= require_tree ./cms/views
#= require_self

$ ->
  _.mixin(_.str.exports())
  
  Backbone.Marionette.Renderer.render = (template, data) ->
    if template?
      throw("Template '" + template + "' not found!") unless JST[template]
      JST[template](data)
    else
      ""

  window._cms = new CMS.Application()

  $(document).on "click", "a:not([data-bypass])", (e) ->
    if _cms
      href = $(@).attr("href")
      if href isnt "#"
        prot = @protocol + "//"
        if href and href.slice(0, prot.length) isnt prot
          e.preventDefault()
          _cms.navigate href
