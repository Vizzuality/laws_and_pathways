class FileInput < Formtastic::Inputs::FileInput
  def to_html
    input_wrapping do
      label_html <<
        file_cache_tag <<
        builder.file_field(method, input_html_options)
    end
  end

  def file_cache_tag
    return unless file.present?
    return unless file.attached?

    builder.hidden_field(
      method,
      value: file&.signed_id
    )
  end

  def file
    object.send(method)
  end
end
