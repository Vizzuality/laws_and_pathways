class CompanyDecorator < Draper::Decorator
  delegate_all

  def isin_as_tags
    isin.split(',')
  end

  def mq_level_tag
    mq_assessment = model.latest_mq_assessment_only_beta_methodologies || model.latest_mq_assessment_without_beta_methodologies
    return if mq_assessment.nil?

    mq_assessment.decorate.level_tag
  end

  def preview_url
    h.tpi_company_url(model.slug, {host: Rails.configuration.try(:tpi_domain)}.compact)
  end
end
