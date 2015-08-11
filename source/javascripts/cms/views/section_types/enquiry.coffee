class CMS.Views.EnquirySection extends CMS.Views.SectionView
  template: "section_types/enquiry"
  tagName: "section"

  bindings:
    "h2.title":
      observe: "title"
    ".section_body":
      observe: "main_html"
      updateMethod: "html"

  onRender: =>
    super
    url = _cms.config('enquiry_form_url')
    @_enquirer = @$el.find('#enquire')
    @_enquirer.data 'url', url
    $.ajax
      url: url
      method: 'get'
      beforeSend: (request) -> 
        request.setRequestHeader('X-PJAX', 'true')
      success: (response) =>
        @_enquirer.html(response)
        @_enquirer.find('form').disable()
