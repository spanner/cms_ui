class CMS.Views.OnecolSection extends CMS.Views.SectionView
  template: "section_types/onecol"
  tagName: "section"

  bindings:
    "h2":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
