class BankAssessmentResult < ApplicationRecord
  belongs_to :assessment, class_name: 'BankAssessment'
  belongs_to :indicator, class_name: 'BankAssessmentIndicator'
end
