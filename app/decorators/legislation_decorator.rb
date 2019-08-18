class LegislationDecorator < Draper::Decorator
  delegate_all

  TITLE_INDEX_LENGTH = 100

  def description
    model.description.html_safe
  end

  def title_summary_link
    h.link_to model.title&.truncate(TITLE_INDEX_LENGTH),
              h.admin_legislation_path(model),
              title: model.title
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

  def document_links
    return [] if model.documents.empty?

    model.documents.map do |document|
      h.link_to document.name,
                document.url,
                target: '_blank',
                title: document.external? ? document.url : nil
    end
  end
end
