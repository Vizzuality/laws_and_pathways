# == Schema Information
#
# Table name: contents
#
#  id           :bigint           not null, primary key
#  title        :string
#  text         :text
#  page_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content_type :string
#  position     :integer
#

FactoryBot.define do
  factory :content do
    page { nil }
    text { 'Content text' }
  end
end
