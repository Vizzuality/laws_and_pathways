class CompanyDecorator < Draper::Decorator
  delegate_all

  def isin_as_tags
    isin.split(',')
  end
end
