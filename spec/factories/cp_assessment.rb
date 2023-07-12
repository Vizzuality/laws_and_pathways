FactoryBot.define do
  factory :cp_assessment, class: CP::Assessment do
    association :cp_assessmentable, factory: :company
    association :sector, factory: :tpi_sector

    assessment_date { 1.year.ago }
    publication_date { 11.months.ago }
    last_reported_year { 2020 }

    assumptions { 'Assumptions about the assessment' }
    cp_alignment_2050 { 'Paris Pledges' }
    cp_alignment_2025 { 'Paris Pledges' }
    cp_alignment_2035 { 'Paris Pledges' }

    region { 'Europe' }
    cp_regional_alignment_2025 { 'Paris Pledges' }
    cp_regional_alignment_2035 { 'Paris Pledges' }
    cp_regional_alignment_2050 { 'Paris Pledges' }

    years_with_targets { [2025, 2030, 2040] }

    emissions do
      {
        2013 => 120,
        2014 => 124,
        2015 => 125,
        2016 => 121,
        2017 => 125,
        2018 => 128
      }
    end
  end
end
