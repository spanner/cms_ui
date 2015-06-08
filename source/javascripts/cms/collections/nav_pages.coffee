# This is a UI convenience and should always be secondary to
# the main pages collection, from which it is selected.
#
class CMS.Collections.NavPages extends Backbone.Collection
  model: CMS.Models.Page
  comparator: "nav_position"
