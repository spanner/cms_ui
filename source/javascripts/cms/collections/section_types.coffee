class CMS.Collections.SectionTypes extends CMS.Collection
  model: CMS.Models.SectionType

  initialize: ->
    section_types = 
      default: 'Standard'
      twocol: "Two columns"
      asided: "Text and quote"
      grid: "Blocks"
      hero: "Hero"
      bigquote: "Big quote"
      bigtext: "Big text"
      carousel: "Carousel"

    for slug, name of section_types
      @add 
        name: name
        slug: slug
