module FileHelper
  def preview_file_tag(file, options = {})
    return unless file.attached?

    title = file.attachment.new_record? ? 'Chosen file' : 'Uploaded file'

    link_to "#{title}: #{file.blob.filename}", rails_blob_path(file), options.merge(target: '_blank')
  end
end
