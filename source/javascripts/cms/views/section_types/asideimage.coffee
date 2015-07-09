class CMS.Views.AsideimageStyler extends CMS.Views.ItemView
  template: "section_types/asideimage_styler"
  events:
    "click a.right": "setRight"
    "click a.left": "setLeft"
    "click a.full": "setFull"

  setRight: () => 
    @model.set "style", "right", stickitChange: true
  setLeft: () => 
    @model.set "style", "left", stickitChange: true
  setFull: () => 
    @model.set "style", "full", stickitChange: true


class CMS.Views.AsideimageSection extends CMS.Views.SectionView
  template: "section_types/asideimage"
  styleMenuView: CMS.Views.AsideimageStyler

  bindings:
    ":el":
      attributes: [
        name: "class"
        observe: "style"
      ]
    "h2":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"
    "aside .caption":
      observe: "caption_html"
      updateMethod: "html"

  onRender: =>
    @model.set('style', 'right') unless @model.get('style')
    super
    @imageOrVideo('half')
    @imagePicker()
    @videoPicker()
    @model.on "change:style", @setStyleSize

  setStyleSize: (model, style) =>
    size = if style is "full" then "full" else "half"
    @_image_or_video.setSize(size)
