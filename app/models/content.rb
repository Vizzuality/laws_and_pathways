class Content < ApplicationRecord
  belongs_to :page
  has_many_attached :images
end
