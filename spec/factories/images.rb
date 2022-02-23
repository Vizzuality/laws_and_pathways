FactoryBot.define do
  factory :image do
    name { 'Image name' }
    link { 'https://example.com' }
    logo { fixture_file_upload(Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.jpg'), 'jpg') }
  end
end
