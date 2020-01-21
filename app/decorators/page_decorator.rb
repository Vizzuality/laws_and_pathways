class PageDecorator < Draper::Decorator
  delegate_all
  decorates_association :contents

  def title_link
    h.link_to model.title, h.send(model.admin_path, model)
  end

  def description
    model.description&.html_safe
  end
end
