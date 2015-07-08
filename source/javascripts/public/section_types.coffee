jQuery ($) ->

  $.fn.slider = ->
    @each ->
      $(@).find('.images').slick
        lazyLoad: 'ondemand'
        infinite: true
        slidesToShow: 1
        slidesToScroll: 1

