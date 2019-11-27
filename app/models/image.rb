class Image < ApplicationRecord
  belongs_to :content
  has_one_attached :logo
end
