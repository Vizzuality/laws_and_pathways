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

class Testimonial < ApplicationRecord
  validates_presence_of :author, :quote
end
