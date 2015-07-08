class CMS.Views.TwocolSection extends CMS.Views.SectionView
  template: "section_types/twocol"
  tagName: "section"

  bindings:
    "h2":
      observe: "title"
    ".col.first":
      observe: "main_html"
      updateMethod: "html"
    ".col.second":
      observe: "secondary_html"
      updateMethod: "html"
