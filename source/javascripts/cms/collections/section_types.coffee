class CMS.Collections.SectionTypes extends CMS.Collection
  model: CMS.Models.SectionType

  initialize: ->
    section_types = 
      default: 'Standard'
      twocol: "Two columns"
      bigtext: "Big text"
      asideimage: "Text and image"
      bigpicture: "Big picture"
      asidequote: "Text and quote"
      bigquote: "Big quote"
      hero: "Hero"
      contents: "Contents"
      links: "Link blocks"

    for slug, name of section_types
      @add 
        name: name
        slug: slug
