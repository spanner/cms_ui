class CMS.Views.Job extends Backbone.Marionette.ItemView
  template: "jobs/job"
  className: "job"

  events: 
    "click a.close": "cancel"

  bindings: 
    ".message": "message"
    ".percentage": 
      observe: "progress"
      onGet: "setProgress"
    ".progress":
      observe: "progress"
      visible: true
    ".bar":
      attributes: [
        name: "style"
        observe: "progress"
        onGet: "setWidth"
      ]
    ":el":
      attributes: [
        name: "class"
        observe: "status"
        onGet: "setClass"
      ]

  initialize: () ->
    @model.on "change:completed", @fadeAfterCompletion

  onRender: () =>
    @stickit()

  setWidth: (value) =>
    "width: #{value}%"
    
  setClass: (value) =>
    "job #{value}"

  setProgress: (value) =>
    if value and value > 0 and value < 96
      "#{value}%"
    
  cancel: (e) =>
    e.preventDefault() if e
    @$el.slideUp () =>
      @model.collection.remove(@model)

  fadeAfterCompletion: () =>
    if @model.get('completed')
      @remove()
      
  remove: () =>
    @$el.fadeOut 2000, () =>
      @$el.remove()


class CMS.Views.JobQueue extends Backbone.Marionette.CollectionView
  childView: CMS.Views.Job
