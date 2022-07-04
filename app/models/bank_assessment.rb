class BankAssessment < ApplicationRecord
  belongs_to :bank
  has_many :bank_assessment_results

  validates_presence_of :assessment_date
end
