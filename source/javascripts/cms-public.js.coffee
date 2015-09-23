#= require lib/modernizr
#= require lib/_slick
#= require lib/_video
#= require_tree ./public
#= require_self

$ ->
  $('section.slides').slider()
  $('section.gallery.blocks').lightbox_slider()
  $('#enquire').enquirer()
  # $('video').video_player()
  