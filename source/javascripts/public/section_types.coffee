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


  $.fn.enquirer = () ->
    @each ->
      new Enquirer(this)
    this

  class Enquirer
    constructor: (element) ->
      @_container = $(element)
      @getForm @_container.data('url')

    getForm: (url) =>
      $.ajax
        url: url
        method: 'get'
        beforeSend: @pjax
        success: @receive

    sendForm: (e) =>
      e?.preventDefault()
      $.ajax
        url: @_form.attr('action')
        data:
          enquiry:
            name: @_form.find('#enquiry_name').val()
            email: @_form.find('#enquiry_email').val()
            message: @_form.find('#enquiry_message').val()
            robot: @_form.find('#enquiry_robot').val()
        method: 'post'
        beforeSend: @pjax
        success: @receive

    receive: (response) =>
      @_container.html(response)
      @_form = @_container.find('form')
      @_form.bind 'submit', @sendForm

    pjax: (request) -> 
      request.setRequestHeader('X-PJAX', 'true')

