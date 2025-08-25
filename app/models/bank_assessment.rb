# == Schema Information
#
# Table name: bank_assessments
#
#  id              :bigint           not null, primary key
#  bank_id         :bigint
#  assessment_date :date             not null
#  notes           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class BankAssessment < ApplicationRecord
  belongs_to :bank
  has_many :results, class_name: 'BankAssessmentResult', dependent: :destroy

  validates_presence_of :assessment_date
  validates :assessment_date, date_after: Date.new(2010, 12, 31)

  def results_by_indicator_type
    # Use only active indicators by default
    results.joins(:indicator)
      .where(bank_assessment_indicators: {active: true})
      .order('bank_assessment_indicators.number')
      .group_by { |r| r.indicator.indicator_type }
  end

  def all_results_by_indicator_type
    # Method to get results from all indicators (including inactive)
    results.includes(:indicator)
      .order('bank_assessment_indicators.number')
      .group_by { |r| r.indicator.indicator_type }
  end

  def active_results_by_indicator_type
    # Explicit method for active indicators only
    results_by_indicator_type
  end

  def active_results?
    results.joins(:indicator).where(bank_assessment_indicators: {active: true}).exists?
  end

  def legacy_results?
    results.joins(:indicator).where(bank_assessment_indicators: {active: false}).exists?
  end
end
