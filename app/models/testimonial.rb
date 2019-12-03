class Testimonial < ApplicationRecord
  validates_presence_of :author, :quote
end
