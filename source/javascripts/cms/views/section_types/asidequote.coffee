class CMS.Views.AsidequoteSection extends CMS.Views.SectionView
  template: "section_types/asidequote"

  bindings:
    "h2":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
    ".quoted":
      observe: "secondary_html"
      updateMethod: "text"
    ".speaker":
      observe: "caption_html"
      updateMethod: "text"

