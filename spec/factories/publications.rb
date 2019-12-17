# == Schema Information
#
# Table name: publications
#
#  id                :bigint           not null, primary key
#  title             :string
#  short_description :text
#  file              :bigint
#  image             :bigint
#  publication_date  :date
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sector_id         :bigint
#

FactoryBot.define do
  factory :publication do
    tpi_sectors { |a| [a.association(:tpi_sector)] }

    title { 'MyString' }
    short_description { 'MyText' }
    publication_date { '2019-12-02' }
    file { fixture_file_upload(Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.pdf'), 'pdf') }
  end
end
