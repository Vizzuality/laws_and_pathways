class TPISectorDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_tpi_sector_path(model)
  end

  def cp_units_list
    model.cp_units.order('valid_since DESC NULLS LAST').map(&:to_s)
  end

  def industry_links
    return [] if model.industries.empty?

    model.industries.order(:name).map do |industry|
      h.link_to industry.name, h.admin_industry_path(industry)
    end
  end

  def preview_url
    return h.tpi_banks_path({host: Rails.configuration.try(:tpi_domain)}.compact) if slug == 'banks'

    h.tpi_sector_url(model.slug, {host: Rails.configuration.try(:tpi_domain)}.compact)
  end
end
