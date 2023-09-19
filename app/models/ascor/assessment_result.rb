class ASCOR::AssessmentResult < ApplicationRecord
  belongs_to :assessment, class_name: 'ASCOR::Assessment', foreign_key: :assessment_id
  belongs_to :indicator, class_name: 'ASCOR::AssessmentIndicator', foreign_key: :indicator_id

  validates_uniqueness_of :indicator_id, scope: :assessment_id
end
