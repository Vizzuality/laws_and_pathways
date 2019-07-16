FactoryBot.define do
  factory :cp_assessment, class: CP::Assessment do
    association :company

    assessment_date { 1.year.ago }
    publication_date { 11.months.ago }

    assumptions { 'Assumptions about the assessment' }

    emissions do
      (2013..2030).map do |year|
        {year => rand(120..140)}
      end.reduce(&:merge)
    end
  end
end
