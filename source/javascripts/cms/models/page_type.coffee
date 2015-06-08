class CMS.Models.PageType extends CMS.Model
  savedAttributes: ['title', 'template', 'default_sections']

  defaults:
    default_sections: ""

  defaultSectionsList: () =>
    (@get('default_sections') || "").split(',')
    