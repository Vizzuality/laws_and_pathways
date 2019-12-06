FactoryBot.define do
  factory :publication do
    association :sector, factory: :tpi_sector

    title { 'MyString' }
    short_description { 'MyText' }
    publication_date { '2019-12-02' }
    file { fixture_file_upload(Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.pdf'), 'pdf') }
  end
end
