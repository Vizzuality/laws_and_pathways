class BankAssessmentResult < ApplicationRecord
  belongs_to :bank_assessment
  belongs_to :bank_assessment_indicator
end
