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

  def date_passed
    return 'n/a' if model.date_passed.nil?

    model.date_passed.to_s(:date_short)
  end

  def litigations_links
    return [] if model.litigations.empty?

    model.litigations.map do |litigation|
      h.link_to litigation.title.truncate(120),
                h.admin_litigation_path(litigation),
                target: '_blank',
                title: litigation.title
    end
  end

  def document_type_links
    return '-' if model.document_types.empty?

    model.document_types.map(&:name)
  end
end
