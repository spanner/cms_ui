class CMS.Views.HeroSection extends CMS.Views.SectionView
  template: "section_types/hero"

  bindings:
    "h1":
      observe: "title"
      updateMethod: "html"

  onRender: =>
    super
    @imageOrVideo('hero')
    @videoPicker()
    @imagePicker()
