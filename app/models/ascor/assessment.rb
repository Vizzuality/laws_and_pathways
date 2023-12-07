# == Schema Information
#
# Table name: ascor_assessments
#
#  id               :bigint           not null, primary key
#  country_id       :bigint           not null
#  assessment_date  :date
#  publication_date :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  notes            :text
#
class ASCOR::Assessment < ApplicationRecord
  belongs_to :country, class_name: 'ASCOR::Country', foreign_key: :country_id

  has_many :results, class_name: 'ASCOR::AssessmentResult', foreign_key: :assessment_id, dependent: :destroy,
                     inverse_of: :assessment

  validates_presence_of :assessment_date

  accepts_nested_attributes_for :results, allow_destroy: true

  scope :currently_published, -> { where('ascor_assessments.publication_date <= ?', DateTime.now) }
end
