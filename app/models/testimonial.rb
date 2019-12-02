class Testimonial < ApplicationRecord
  has_one_attached :avatar
  validates_presence_of :author, :quote, :role
end
