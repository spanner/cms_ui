#= require hamlcoffee
#= require lib/jquery
#= require lib/jquery.cookie
#= require lib/underscore
#= require lib/underscore.string
#= require lib/backbone
#= require lib/backbone.cocktail
#= require lib/backbone.marionette

#= require lib/utilities

#= require ./cms/application
#= require ./cms/router
#= require ./cms/config

#= require_tree ./templates
#= require_tree ./cms/models
#= require_tree ./cms/collections
#= require_tree ./cms/views
#= require_self

$ ->
  new CMS.Application()
