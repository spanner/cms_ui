jQuery ($) ->

  $.fn.slider = ->
    @each ->
      slides = $(@).find('.images')
      slides.slick
        lazyLoad: 'ondemand'
        infinite: true
        slidesToShow: 1
        slidesToScroll: 1

  $.fn.lightbox_slider = ->
    @each ->
      slides = $(@).find('.images')
      slides.slickLightbox
        itemSelector: 'a.zoom'
        slick:
          lazyLoad: 'ondemand'
          infinite: true
          slidesToShow: 1
          slidesToScroll: 1
          

