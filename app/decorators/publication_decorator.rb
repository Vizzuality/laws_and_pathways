class PublicationDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_publication_path(model)
  end
end
