class CMS.Views.ManagerLayout extends CMS.Views.LayoutView
  template: "layouts/manager"

  events:
    "click #manager_menu a": "toggleStyler"

  onRender: =>
    #TODO init css/properties editor on left
    @stickit()

  # When user model is ready, render a menu of her sites.
  # If slug and path have been given, pass them down.
  #
  show: (site_slug, page_path) =>
    @model.whenReady =>
      @_sites_layout = new CMS.Views.SitesLayout
        el: @$el.find("#sites")
        collection: @model.sites
      @_sites_layout.render()
      @_sites_layout.show(site_slug, page_path)

