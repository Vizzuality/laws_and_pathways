class LegislationDecorator < Draper::Decorator
  delegate_all

  LEGISLATION_TITLE_LENGTH = 100
  LITIGATION_TITLE_LENGTH = 120

  def id
    model.id
  end

  def description
    model.description&.html_safe
  end

  def title_summary_link
    h.link_to model.title&.truncate(LEGISLATION_TITLE_LENGTH),
              h.admin_legislation_path(model),
              title: model.title
  end

  def legislation_type
    model.legislation_type.humanize
  end

  def litigations_links
    return [] if model.litigations.empty?

    model.litigations.map do |litigation|
      h.link_to litigation.title.truncate(LITIGATION_TITLE_LENGTH),
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

  def instrument_links
    model.instruments.map do |instrument|
      h.link_to instrument.name,
                h.admin_instrument_path(instrument),
                target: '_blank',
                title: instrument.name
    end
  end

  def governance_links
    model.governances.map do |governance|
      h.link_to governance.name,
                h.admin_governance_path(governance),
                target: '_blank',
                title: governance.name
    end
  end

  def laws_sector_links
    model.laws_sectors.map do |laws_sector|
      h.link_to laws_sector.name,
                h.admin_laws_sector_path(laws_sector),
                target: '_blank',
                title: laws_sector.name
    end
  end

  def as_json(_ = {})
    super(methods: :display_name)
  end
end
