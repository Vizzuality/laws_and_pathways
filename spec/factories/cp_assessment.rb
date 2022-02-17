FactoryBot.define do
  factory :cp_assessment, class: CP::Assessment do
    # association :company

    assessment_date { 1.year.ago }
    publication_date { 11.months.ago }
    last_reported_year { 2020 }

    assumptions { 'Assumptions about the assessment' }
    cp_alignment { 'Paris Pledges' }
    cp_alignment_2025 { 'Paris Pledges' }
    cp_alignment_2035 { 'Paris Pledges' }

    years_with_targets { [2025, 2030, 2040] }

    emissions do
      (2013..2030).map do |year|
        {year => rand(120..140)}
      end.reduce(&:merge)
    end
  end
end
