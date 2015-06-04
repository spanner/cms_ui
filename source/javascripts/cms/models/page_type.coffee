class CMS.Models.PageType extends CMS.Model
  savedAttributes: ['title', 'template', 'default_sections']

  defaults:
    default_sections: ""
    default_sections_list: []

  build: =>
    @on "change:default_sections", @setDefaultSectionsList

  setDefaultSectionsList: () =>
    @set "default_sections_list", (@get('default_sections') || "").split(',')