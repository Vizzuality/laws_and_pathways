class PageDecorator < Draper::Decorator
  delegate_all

  def description
    model.description.html_safe
  end
end
