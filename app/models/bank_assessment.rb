class BankAssessment < ApplicationRecord
  belongs_to :bank

  validates_presence_of :assessment_date
end
