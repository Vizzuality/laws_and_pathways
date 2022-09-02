# == Schema Information
#
# Table name: publications
#
#  id                :bigint           not null, primary key
#  title             :string
#  short_description :text
#  file              :bigint
#  image             :bigint
#  publication_date  :datetime
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryBot.define do
  factory :publication do
    tpi_sectors { |a| [a.association(:tpi_sector)] }

    title { 'MyString' }
    author { 'Author' }
    short_description { 'MyText' }
    publication_date { '2019-12-02' }
    file { fixture_file_upload(Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.pdf'), 'pdf') }

    trait :published do
      publication_date { 20.days.ago }
    end

    trait :not_published do
      publication_date { 12.days.from_now }
    end
  end
end
