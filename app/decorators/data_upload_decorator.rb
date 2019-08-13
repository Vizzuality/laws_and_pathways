class DataUploadDecorator < Draper::Decorator
  delegate_all

  def details
    HashDecorator.decorate(model.details).key_values
  end

  def file
    h.link_to model.file.filename, h.rails_blob_path(model.file, disposition: 'attachment')
  end
end
