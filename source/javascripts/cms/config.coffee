# The configurator notices (or is given) the current environment,
# and returns the appropriate value for a given variable name.

class CMS.Config
  defaults: 
    api_url: "http://api.cupboard.org/api/1/"
    cookie_domain: ".cupboard.org"
    cookie_name: "cms_blah"
    published_domain: "cupboard.org"
    published_protocol: "http"
    enquiry_form_url: "http://igf.spanner.org/enquire"
    logging: false

  development:
    api_url: "http://api.cms.dev/api/1/"#"http://localhost:9292/"#
    cookie_domain: ".cms.dev"
    cookie_name: "cms_blah"
    published_domain: "cms.dev"
    published_protocol: "http"
    enquiry_form_url: "http://igf.dev/enquire"
    logging: true

  constructor: (options={}) ->
    options.environment ?= @guessEnvironment()
    @_settings = _.defaults options, @[options.environment], @defaults

  guessEnvironment: () ->
    prod = new RegExp(/cupboard\.org/)
    dev = new RegExp(/cms\.dev/)
    if prod.test(window.location.href)
      "production"
    else# if dev.test(window.location.href)
      "development"

   settings: =>
     @_settings

   get: (key) =>
     @_settings[key]
