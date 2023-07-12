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
  has_many :results, class_name: 'BankAssessmentResult'

  validates_presence_of :assessment_date
  validates :assessment_date, date_after: Date.new(2010, 12, 31)

  def results_by_indicator_type
    results.includes(:indicator).order('bank_assessment_indicators.number').group_by { |r| r.indicator.indicator_type }
  end
end
