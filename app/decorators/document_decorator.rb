class DocumentDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_document_path(model)
  end

  def open_link
    h.link_to model.name, model.url, target: '_blank'
  end

  def last_verified_on
    return 'N/A' if model.uploaded?

    model.last_verified_on
  end
end
