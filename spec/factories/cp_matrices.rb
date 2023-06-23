FactoryBot.define do
  factory :cp_matrix, class: 'CP::Matrix' do
    association :cp_assessment

    portfolio { 'Mortgages' }
    cp_alignment_2050 { 'Paris Pledges' }
    cp_alignment_2025 { 'Paris Pledges' }
    cp_alignment_2035 { 'Paris Pledges' }
  end
end
