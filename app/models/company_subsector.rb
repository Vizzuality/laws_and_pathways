# == Schema Information
#
# Table name: company_subsectors
#
# id         :bigint           not null, primary key
# company_id :bigint           not null
# subsector  :string           not null
# created_at :datetime         not null
# updated_at :datetime         not null
#
class CompanySubsector < ApplicationRecord
  belongs_to :company
  has_many :cp_assessments, class_name: 'CP::Assessment'
  has_one :latest_cp_assessment, -> {
                                   currently_published.order(assessment_date: :desc)
                                 }, class_name: 'CP::Assessment'
  has_one :latest_cp_assessment_regional, -> { currently_published.regional.order(assessment_date: :desc) },
          class_name: 'CP::Assessment'
end
