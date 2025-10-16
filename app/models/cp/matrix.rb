# == Schema Information
#
# Table name: cp_matrices
#
#  id                :bigint           not null, primary key
#  cp_assessment_id  :bigint           not null
#  portfolio         :string           not null
#  cp_alignment_2025 :string
#  cp_alignment_2035 :string
#  cp_alignment_2050 :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class CP::Matrix < ApplicationRecord
  belongs_to :cp_assessment, class_name: 'CP::Assessment'

  validates :portfolio, inclusion: {in: CP::Portfolio::NAMES, allow_blank: true}, presence: true

  with_options allow_nil: true, allow_blank: true, inclusion: {in: CP::Alignment::ALLOWED_NAMES} do
    validates :cp_alignment_2027
    validates :cp_alignment_2030
    validates :cp_alignment_2035
    validates :cp_alignment_2050
  end
end
