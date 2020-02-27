# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  link       :string
#  content_id :bigint           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Image < ApplicationRecord
  belongs_to :content
  has_one_attached :logo

  validates :logo, attached: true
end
