class LegislationDecorator < Draper::Decorator
  delegate_all

  TITLE_INDEX_LENGTH = 100

  def title_summary_link
    h.link_to model.title&.truncate(TITLE_INDEX_LENGTH),
              h.admin_legislation_path(model),
              title: model.title
  end

  def framework
    model.framework&.humanize
  end
end
