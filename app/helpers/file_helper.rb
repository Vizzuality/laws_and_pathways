module FileHelper
  def preview_file_tag(file, options = {})
    return unless file.attached?

    link_to "Uploaded file: #{file.blob.filename}", rails_blob_path(file), options.merge(target: '_blank')
  end
end
