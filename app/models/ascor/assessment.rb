class ASCOR::Assessment < ApplicationRecord
  belongs_to :country, class_name: 'ASCOR::Country', foreign_key: :country_id

  has_many :results, class_name: 'ASCOR::AssessmentResult', foreign_key: :assessment_id, dependent: :destroy,
                     inverse_of: :assessment

  validates_presence_of :assessment_date

  accepts_nested_attributes_for :results, allow_destroy: true
end
