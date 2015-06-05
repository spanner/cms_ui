# Sections are saved as a nested resource within the page object
# so that we can offer a nice simple save and publish workflow.
# Once we start reusing sections then something more clever will
# be required.
#
class CMS.Collections.Sections extends CMS.Collection
  model: CMS.Models.Section
  comparator: "position"

  initialize: (array, opts) ->
    @page = opts.page

  toJSON: =>
    m.toJSON() for m in @models
