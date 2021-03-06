#= require hamlcoffee
#= require lib/_jquery
#= require lib/_jquery.cookie
#= require lib/_rangy
#= require lib/_underscore
#= require lib/_underscore.string
#= require lib/_backbone
#= require lib/_backbone.cocktail
#= require lib/_backbone.marionette
#= require lib/_backbone.stickit
#= require lib/_codemirror
#= require lib/_medium
#= require lib/_slick

#= require lib/utilities
#= require lib/components
#= require ./cms/application
#= require ./cms/config
#= require ./cms/mixins

#= require_tree ./templates
#= require_tree ./cms/models
#= require_tree ./cms/collections
#= require_tree ./cms/views
#= require_self

$ ->
  _.mixin(_.str.exports())

  $(document).on "click", "a:not([data-bypass])", (e) ->
    if _cms
      href = $(@).attr("href")
      if href isnt "#"
        prot = @protocol + "//"
        if href and href.slice(0, prot.length) isnt prot
          has_target = _.str.contains(href, "#")
          e.preventDefault()# unless has_target
          _cms.navigate href, trigger: !has_target

  new CMS.Application().start()