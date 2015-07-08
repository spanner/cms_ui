class CMS.Views.BigpictureSection extends CMS.Views.SectionView
  template: "section_types/bigpicture"

  bindings:
    ".caption":
      observe: "main_html"
      updateMethod: "html"

  onRender: =>
    super
    @imageOrVideo('hero')
    @imagePicker()
    @videoPicker()
