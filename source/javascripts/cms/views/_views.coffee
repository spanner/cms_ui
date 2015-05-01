class CMS.Views.LayoutView extends Backbone.Marionette.LayoutView

  log: (message) =>
    if _cms.logging()
      console.log "#{@constructor.name} view", message



class CMS.Views.ItemView extends Backbone.Marionette.ItemView

  log: (message) =>
    if _cms.logging()
      console.log "#{@constructor.name} view", message