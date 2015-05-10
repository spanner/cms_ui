# The configurator notices (or is given) the current environment,
# and returns the appropriate value for a given variable name.

class CMS.Config
  defaults: 
    api_url: "https://api.cms.io/"
    cookie_domain: ".cms.io"
    cookie_name: "cms_prod"
    logging: false

  development:
    api_url: "http://localhost:9292/"#"http://api.cms.dev/"#
    cookie_domain: ".cms.dev"
    cookie_name: "cms_dev"
    logging: true

  constructor: (options={}) ->
    options.environment ?= @guessEnvironment()
    @_settings = _.defaults options, @[options.environment], @defaults

  guessEnvironment: () ->
    prod = new RegExp(/cms\.io/)
    dev = new RegExp(/cms\.dev/)
    if prod.test(window.location.href)
      "production"
    else# if dev.test(window.location.href)
      "development"

   settings: =>
     @_settings

   get: (key) =>
     @_settings[key]
