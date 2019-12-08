# == Schema Information
#
# Table name: testimonials
#
#  id         :bigint           not null, primary key
#  quote      :string
#  author     :string
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :testimonial do
    quote { 'I loved the site' }
    author { 'John Stewart' }
    role { 'Boss at his Company' }
  end
end
