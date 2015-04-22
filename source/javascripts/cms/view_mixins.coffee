## Mixins
#
# Common view and model functionality is bundled in shared components that can be mixed in just by calling
#
#   @mixin '...'
#
# In a view class definition. 
#
# Warning: beware of this-context. Mixed-in functions should always be single-arrowed (so as not to 
# keep them bound to the mixin class) but this can make internal reference difficult. 


# ### View Mixins
CMS.Mixins.Crumbed =
  setModel: (model) ->
    @model = model
    if @model
      @stickit()
    else
      @unstickit()

Cocktail.mixins =
  crumbed: CMS.Mixins.Crumbed
