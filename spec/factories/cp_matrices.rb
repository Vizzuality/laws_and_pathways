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
FactoryBot.define do
  factory :cp_matrix, class: 'CP::Matrix' do
    association :cp_assessment

    portfolio { 'Mortgages' }
    cp_alignment_2050 { 'Paris Pledges' }
    cp_alignment_2025 { 'Paris Pledges' }
    cp_alignment_2035 { 'Paris Pledges' }
  end
end
