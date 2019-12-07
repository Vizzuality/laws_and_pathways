# == Schema Information
#
# Table name: pages
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  slug        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  menu        :string
#  type        :string
#

FactoryBot.define do
  factory :page do
    title { 'MyString' }
    description { 'MyText' }
    slug { 'MyString' }
    type { 'TPIPage' }
  end
end
