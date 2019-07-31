class TargetDecorator < Draper::Decorator
  delegate_all

  def description
    model.description.html_safe
  end

  def legislation_links
    return [] if model.legislations.empty?

    model.legislations.map do |legislation|
      h.link_to legislation.title, h.admin_legislation_path(legislation), target: '_blank'
    end
  end
end
