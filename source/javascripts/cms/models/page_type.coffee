class CMS.Models.PageType extends CMS.Model
  savedAttributes: ['id', 'title', 'html', 'default_sections']

  defaults:
    default_sections: ""

  defaultSectionsList: () =>
    (@get('default_sections') || "").split(',')
    