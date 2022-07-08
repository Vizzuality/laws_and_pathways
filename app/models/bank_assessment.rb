class BankAssessment < ApplicationRecord
  belongs_to :bank
  has_many :results, class_name: 'BankAssessmentResult'

  validates_presence_of :assessment_date

  def results_by_indicator_type
    results.includes(:indicator).group_by { |r| r.indicator.indicator_type }
  end
end
