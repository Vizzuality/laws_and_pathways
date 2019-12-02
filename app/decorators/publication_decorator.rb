class PublicationDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_publication_path(model)
  end

  def file_link
    h.link_to model.file.filename, h.rails_blob_path(model.file, disposition: 'attachment')
  end
end
