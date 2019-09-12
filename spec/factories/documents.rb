# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  type              :string           not null
#  external_url      :text
#  language          :string
#  last_verified_on  :date
#  documentable_type :string
#  documentable_id   :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  discarded_at      :datetime
#

FactoryBot.define do
  factory :document do
    name { 'Cool document' }
    language { 'en' } # for available options, see Language.common.map(&:iso_639_1)
    type { 'external' }
    external_url { 'https://test.com' }
    last_verified_on { 10.days.ago }

    documentable { |d| d.association(:legislation) }

    factory :document_uploaded do
      type { 'uploaded' }
      file { TestFiles.pdf }
      external_url { nil }
    end
  end
end
