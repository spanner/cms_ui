class CMS.Views.BigquoteSection extends CMS.Views.SectionView
  template: "section_types/bigquote"
  tagName: "section"

  bindings:
    ".quoted":
      observe: "secondary_html"
      updateMethod: "text"
    ".speaker":
      observe: "caption_html"
      updateMethod: "text"
