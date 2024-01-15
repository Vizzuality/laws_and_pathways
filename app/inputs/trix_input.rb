class TrixInput < Formtastic::Inputs::StringInput
  def to_html
    input_wrapping do
      editor_tag_params = {
        input: input_html_options[:id],
        'data-direct-upload-url': Rails.application.routes.url_helpers.rails_direct_uploads_path,
        'data-blob-url-template': Rails.application.routes.url_helpers.rails_service_blob_path(':signed_id', ':filename'),
        class: 'trix-content'
      }

      editor_tag_params['data-controller'] = 'embed-trix' if options[:embed_youtube]

      editor_tag = template.content_tag('trix-editor', '', editor_tag_params)
      hidden_field = builder.hidden_field(method, input_html_options)

      editor = template.content_tag('div', hidden_field + editor_tag, class: 'trix-editor-wrapper')

      label_html + editor
    end
  end
end
