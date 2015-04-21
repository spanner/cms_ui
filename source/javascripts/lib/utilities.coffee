jQuery ($) ->

  # **$.makeGuid** is a neat little rfc4122 generator cribbed from 
  # http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
  #
  $.makeGuid = ()->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random()*16|0
      v = if c is 'x' then r else r & 0x3 | 0x8
      v.toString 16