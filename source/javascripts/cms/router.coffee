class CMS.Router extends Backbone.Router

  constructor: ->
    @handlers = []
    super

  handle: (fragment) =>
    handler = _.find @handlers, (handler) ->
      handler.route.test(fragment)
    if handler?
      handler.callback(fragment)
      true
    else
      false

  route: (route, name, fn) =>
    route = @_routeToRegExp(route) unless _.isRegExp(route)
    if _.isFunction(name)
      fn = name
      name = ''
    unless fn?
      fn = this[name]
    @handlers.unshift
      route: route
      callback: (fragment) =>
        args = @_extractParameters(route, fragment)
        @execute(fn, args, name)

  # _extractParameters is modified to append the whole matched fragment except the final *path
  # if there is no final *path then results will be strange, but probably ignored.
  #
  _extractParameters: (route, fragment) =>
    params = route.exec(fragment)
    whole_path = params.shift()
    null_marker = params.pop()
    unused_path = params[params.length - 1]
    used_path = whole_path.replace(new RegExp("#{unused_path}$"), "")
    _.map params, (param, i) ->
      if param then decodeURIComponent(param) else null

  # Here we modify exec and _extractParameters to pass through the used path segment.
  execute: (callback, args, name) =>
    callback?.apply(this, args)
