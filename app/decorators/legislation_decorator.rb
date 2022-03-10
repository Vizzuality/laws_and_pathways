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
                rel: 'noopener noreferrer',
                title: document.external? ? document.url : nil
    end
  end

  def target_links
    model.targets.map do |target|
      h.link_to target.description,
                h.admin_target_path(target),
                target: '_blank',
                title: target.description
    end
  end

  def instrument_links
    model.instruments.map do |instrument|
      title = "[#{instrument.instrument_type.name}] #{instrument.name}"

      h.link_to title,
                h.admin_instrument_path(instrument),
                target: '_blank',
                title: title
    end
  end

  def theme_links
    model.themes.map do |theme|
      h.link_to theme.name,
                h.admin_theme_path(theme),
                target: '_blank',
                title: theme.name
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

  def preview_url
    if model.law?
      return h.cclow_geography_law_url(
        model.geography.slug, model.slug, {host: Rails.configuration.try(:cclow_domain)}.compact
      )
    end

    h.cclow_geography_policy_url(
      model.geography.slug, model.slug, {host: Rails.configuration.try(:cclow_domain)}.compact
    )
  end

  def instruments_csv
    model.instruments.map do |instrument|
      [instrument.name, instrument.instrument_type.name].join('|')
    end.join(';')
  end

  def themes_csv
    model.themes.map do |theme|
      [theme.name, theme.theme_type.name].join('|')
    end.join(';')
  end

  def as_json(_ = {})
    super(methods: :display_name)
  end
end
