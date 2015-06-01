jQuery ($) ->

  $.fn.carousel = ->
    @each ->
      new Carousel(@)




  $.fn.masthead = () ->
    @each ->
      new Masthead(@)
    @
    
  $.fn.is_pinned = () ->
    @is('pinned') or @parents('.pinned').length

  class Masthead
    constructor: (element) ->
      @_masthead = $(element)
      @_container = @_masthead.find('.container')
      @_logo = @_container.find('#logo')
      @_width = @_logo.width()
      @_height = @_logo.height()
      @_aspect_ratio = @_width / @_height
      @_offset = @_masthead.offset()
      @_pinned = false
      
      @_min_height = 40
      @_threshold = 16
      $(window).on 'scroll touchmove resize', @setPin
      @setPin()

    setPin: (e) =>
      y = window.pageYOffset
      if y > @_threshold
        @pin() unless @_pinned
        # h = @_height - (3 * Math.sqrt(y - @_threshold))
        # h = @_min_height if h < @_min_height
        # h = @_height if h > @_height
        # @_logo.css
        #   height: h
        #   width: h * @_aspect_ratio
      else
        @unpin() if @_pinned
        # @_logo.css
        #   height: @_height
        #   width: @_width

    # *pin* just gives the header position:fixed
    pin: () =>
      @_masthead.stop().addClass('pinned')
      @_pinned = true

    # *unpin* releases the header again.
    unpin: () =>
      @_masthead.stop().removeClass('pinned')
      @_pinned = false
