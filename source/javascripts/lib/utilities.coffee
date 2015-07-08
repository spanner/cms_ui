jQuery ($) ->
  
  $.fn.removeIfEmpty = () ->
    @each ->
      $el = $(@)
      $el.remove() if _.isBlank $el.text()

  $.easing.glide = (x, t, b, c, d) ->
    -c * ((t=t / d-1)*t*t*t - 1) + b

  $.easing.boing = (x, t, b, c, d, s) ->
    s ?= 1.70158;
    c*((t=t / d-1)*t*((s+1)*t + s) + 1) + b

  $.easing.expo = (x, t, b, c, d) ->
    (t==d) ? b+c : c * (-Math.pow(2, -10 * t / d) + 1) + b

  # **$.makeGuid** is a neat little rfc4122 generator cribbed from 
  # http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
  #
  $.makeGuid = ()->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random()*16|0
      v = if c is 'x' then r else r & 0x3 | 0x8
      v.toString 16