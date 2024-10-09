module FileHelper
  def preview_file_tag(file, options = {})
    return unless file.attached?
    return unless file.persisted? # TODO: remove when using direct upload to uploading file

    link_to "Uploaded file: #{file.blob.filename}", rails_blob_path(file), options.merge(target: '_blank')
  end

  def format_of(file)
    Mime::Type.lookup(file.content_type).symbol
  end
end
