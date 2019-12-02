FactoryBot.define do
  factory :publication do
    title { 'MyString' }
    short_description { 'MyText' }
    publication_date { '2019-12-02' }
    file { fixture_file_upload(Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.pdf'), 'pdf') }
  end
end
