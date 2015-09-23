jQuery ($) ->

  $.fn.video_player = ->
    @each ->
      player = videojs @, {}, ->
        console.log('player', @)
        @play()
