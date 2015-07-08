jQuery ($) ->

  $.fn.slider = ->
    @each ->
      slides = $(@).find('.images')
      slides.slick
        lazyLoad: 'ondemand'
        infinite: true
        slidesToShow: 1
        slidesToScroll: 1

