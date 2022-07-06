class BankDecorator < Draper::Decorator
  delegate_all

  def isin_as_tags
    isin.split(',')
  end

  # def preview_url
  #   h.tpi_company_url(model.slug, {host: Rails.configuration.try(:tpi_domain)}.compact)
  # end
end
