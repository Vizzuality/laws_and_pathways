# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  link       :string
#  content_id :bigint           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :image do
    name { 'Image name' }
    link { 'https://example.com' }
    logo { fixture_file_upload(Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.jpg'), 'jpg') }
  end
end
