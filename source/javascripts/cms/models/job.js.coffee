class CMS.Models.Job extends Backbone.Model

  initialize: () ->
    @set('status', 'active') unless @get("status")?
    @set('progress', 0) unless @get("progress")?
    @on "change:progress", @completeIfCompleted

  setProgress: (p) =>
    if p.lengthComputable
      perc = Math.round(10000 * p.loaded / p.total) / 100.0
      @set("progress", perc)

  complete: () =>
    @set('completed', true)

  setCompleted: (value) =>
    @set('completed', value)

  error: (error) =>
    _cms.debug "error", error

  completeIfCompleted: (model, progress) =>
    if progress is 100
      @setCompleted(true)
