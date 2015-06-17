class CMS.Collections.SectionTypes extends CMS.Collection
  model: CMS.Models.SectionType

  initialize: ->
    section_types = 
      default: 'Standard'
      twocol: "Two columns"
      asideimage: "Text and image"
      asidequote: "Text and quote"
      links: "Link blocks"
      hero: "Hero"
      bigquote: "Big quote"
      bigtext: "Big text"

    for slug, name of section_types
      @add 
        name: name
        slug: slug
