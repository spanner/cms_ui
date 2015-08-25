$ ->

  $.fn.masthead = () ->
    @each ->
      new Masthead(this)

  class Masthead
    constructor: (element) ->
      @_mh = $(element)
      @_logo = @_mh.find('#logo')
      @_full_logo = @_logo.find('a')
      @_nav_menu_link = @_mh.find('#nav_menu_head a')
      @_nav = @_mh.find('#nav')
      @_links = @_mh.find('#links')
      @_lt = parseInt(@_links.css('margin-top'))
      @_pt = parseInt(@_mh.css('padding-top'))
      @_w = @_logo.width()
      @_h = @_logo.height()
      @_a =  @_w / @_h
      @_nav_menuing = @_nav_menu_link.is(':visible')
      $(window).on 'scroll', @scale
      $(window).on 'resize', @recalculate
      @_nav_menu_link.click @toggleNav
      @recalculate()

    recalculate: () =>
      @_t = $('h1').offset().top - 10
      @scale()

    scale: (e) =>
      d = Math.abs(window.pageYOffset / @_t)
      d = 0 if d < 0
      d = 1 if d > 1
      @_mh.css
        'border-bottom-color': "rgba(255,255,255,#{d / 3})"
        'background-color': "rgba(0,0,0,#{d * 0.85})"

  $('#masthead').masthead()
