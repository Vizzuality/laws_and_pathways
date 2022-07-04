class BankAssessment < ApplicationRecord
  belongs_to :bank
  has_many :results, class_name: 'BankAssessmentResult'

  validates_presence_of :assessment_date
end
