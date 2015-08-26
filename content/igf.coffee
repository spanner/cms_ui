$ ->

  $.fn.masthead = () ->
    @each ->
      new Masthead(this)

  class Masthead
    constructor: (element) ->
      @_min = 66
      @_max = 120
      @_travel = @_max - @_min
      @_mh = $(element)
      @_logo = @_mh.find('#logo')
      @_nav_menu_link = @_mh.find('#nav_menu_head a')
      @_nav = @_mh.find('#nav')
      @_links = @_mh.find('#links')
      @_lt = parseInt(@_links.css('margin-top'))
      @_pt = parseInt(@_mh.css('padding-top'))
      @_w = @_logo.width()
      @_h = @_logo.height()
      @_a =  @_w / @_h
      @_y = window.pageYOffset
      @_last_y = @_y
      @_nav_menuing = @_nav_menu_link.is(':visible')
      if @_nav_menuing
        # small-screen touch device
        @_nav_menu_link.click @toggleNav
        $(window).on 'scroll', @setBackground
      else if Modernizr.touch
        # large-screen touch device
        $(window).on 'scroll', @setNavProperties
      else
        # normal mousy web browser
        $(window).on 'scroll', @setBackground
      $(window).on 'resize', @recalculate
      @recalculate()

    recalculate: () =>
      @_t = $('h1').offset()?.top ? 100
      @setNavProperties()

    setNavProperties: (e) =>
      @_y = window.pageYOffset
      @setSize()
      @_last_y = @_y
      @setTimer()

    setSize: () =>
      if @_y < @_last_y
        @_base_y ?= @_last_y
        @setMenuHeight(@_min + @_base_y - @_y)
      else if @_base_y
        h = @_base_y - @_y
        if h <= 0
          @reset()
        else if h >= @_travel
          @setMenuHeight(@_max)
          @_base_y = @_y + @_travel
        else
          @setMenuHeight(@_min + h)
      else
        @setBackground()

    reset: () =>
      @setMenuHeight(@_min)
      @_base_y = undefined

    setMenuHeight: (h) =>
      h = @_max if h > @_max
      h = @_min if h < @_min
      d = (h - @_min) / (@_max - @_min)
      bgd = Math.abs(@_y / @_t)
      bgd = d if d > bgd
      bgd = 0 if bgd < 0
      bgd = 1 if bgd > 1
      @_mh.css
        'height': h
        'border-bottom-color': "rgba(255,255,255,#{bgd / 3})"
        'background-color': "rgba(0,0,0,#{bgd * 0.85})"
      @_logo.css
        'width': 120 + (60 * d)
        'height': 50 + (25 * d)
        'margin-left': -42 * d
        'margin-top': 16 * d
        'margin-right': 26 - (10 * d)
        'margin-bottom': 16 * d

    setBackground: () =>
      @_y = window.pageYOffset
      d = Math.abs(@_y / @_t)
      d = 0 if d < 0
      d = 1 if d > 1
      @_mh.css
        'border-bottom-color': "rgba(255,255,255,#{d / 3})"
        'background-color': "rgba(0,0,0,#{d * 0.85})"

    setTimer: () =>
      clearTimeout @_timer if @_timer
      @_timer = setTimeout @reset, 4000

    toggleNav: (e) =>
      e?.preventDefault()
      @_mh.toggleClass('menu')



  $('#masthead').masthead()
