class TrixInput < Formtastic::Inputs::StringInput
  def to_html
    input_wrapping do
      editor_tag_params = {
        input: input_html_options[:id],
        class: 'trix-content'
      }

      editor_tag = template.content_tag('trix-editor', '', editor_tag_params)
      hidden_field = builder.hidden_field(method, input_html_options)

      editor = template.content_tag('div', hidden_field + editor_tag, class: 'trix-editor-wrapper')

      label_html + editor
    end
  end
end
