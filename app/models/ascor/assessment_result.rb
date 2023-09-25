# == Schema Information
#
# Table name: ascor_assessment_results
#
#  id            :bigint           not null, primary key
#  assessment_id :bigint           not null
#  indicator_id  :bigint           not null
#  answer        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  source        :string
#  year          :integer
#
class ASCOR::AssessmentResult < ApplicationRecord
  belongs_to :assessment, class_name: 'ASCOR::Assessment', foreign_key: :assessment_id
  belongs_to :indicator, class_name: 'ASCOR::AssessmentIndicator', foreign_key: :indicator_id

  validates_uniqueness_of :indicator_id, scope: :assessment_id
end
