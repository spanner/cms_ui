class CMS.Collections.SectionTypes extends CMS.Collection
  model: CMS.Models.SectionType

  initialize: ->
    for name in ['default', 'twocol', 'asided', 'grid', 'hero', 'bigquote', 'bigtext', 'carousel']
      @add name: name
