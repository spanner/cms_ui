class CMS.Views.AsidequoteStyler extends CMS.Views.ItemView
  template: "section_types/asidequote_styler"
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


class CMS.Views.AsidequoteSection extends CMS.Views.SectionView
  template: "section_types/asidequote"
  styleMenuView: CMS.Views.AsidequoteStyler

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
    ".quoted":
      observe: "secondary_html"
      updateMethod: "text"
    ".speaker":
      observe: "caption_html"
      updateMethod: "text"

  onRender: =>
    @model.set('style', 'right') unless @model.get('style')
    super
